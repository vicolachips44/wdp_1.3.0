package org.decatime.wdpsrv;
#if !flash
import flash.display.Sprite;
import flash.events.Event;
import org.decatime.ui.BaseVisualElement;
import org.decatime.Facade;
import org.decatime.events.IObserver;
import org.decatime.events.IObservable;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.layouts.LayoutContent;
import org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import org.decatime.ui.canvas.background.GridBackGround;
import org.decatime.ui.canvas.remote.Server;
import flash.geom.Rectangle;
import sys.net.Host;

class App extends BaseVisualElement implements IObserver {
	private var layout:BoxLayout;
	public var canvas:RemoteDrawingSurface;
	private var hostIp:String;
	private var hostPort:Int;

	public function new(hostIp:String, hostPort:Int) {
		super('WonderpadServer');
		buttonMode = false;
		this.hostIp = hostIp;
		this.hostPort = hostPort;
		Facade.getInstance().addListener(this);
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic): Void {
		switch (name) {
			case Facade.EV_INIT:
				initializeComponent();
		}
	}

	public function getEventCollection(): Array<String> {
		return [
			Facade.EV_INIT
		];
	}

	public override function refresh(r:Rectangle): Void {
		super.refresh(r);
		// in order to resize our content we need to override this method.
		layout.refresh(r);

	}

	private function initializeComponent(): Void {
		initLayout(); // the main layout for this application

		canvas = new RemoteDrawingSurface('drawingSurface');
		layout.layoutContents.get(1).setItem(canvas);
		addChild(canvas);
		Server.start(canvas, hostIp, hostPort);
	}

	private function initLayout(): Void {
		layout = new BoxLayout(
			this, 
			DirectionType.VERTICAL, 
			'mainApplication_defaultBoxLayout'
		);

		layout.layoutContents.set(1, new LayoutContent(layout, 1.0));
	}
}
#end