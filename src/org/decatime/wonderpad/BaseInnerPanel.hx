package org.decatime.wonderpad;

import flash.geom.Rectangle;

import org.decatime.ui.BaseVisualElement;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.layouts.LayoutContent;
import org.decatime.ui.Label;
import org.decatime.ui.PngButton;
import org.decatime.Facade;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;

class BaseInnerPanel extends BaseVisualElement implements IObserver {
	private static var NAMESPACE:String = "org.decatime.wonderpad.BaseInnerPanel: ";
	private static var EVT_BACK_BUTTON:String = NAMESPACE + "EVT_BACK_BUTTON";

	private var layout:BoxLayout;
	private var app:App;
	private var clientArea:LayoutContent;

	public function new() {
		super('BaseInnerPanel');
		this.buttonMode = false;
		this.elBackColor = 0xffffff;
		this.app = cast(Facade.getInstance().getRoot(), App);
		initLayout();

	}

	public override function refresh(r:Rectangle): Void {
		super.refresh(r);
		layout.refresh(r);
	}

	private function getPanelTitle():String {
		throw "override me !!";
		return "is this a joke ?";
	}

	private function initLayout(): Void {
		layout = new BoxLayout(this, DirectionType.VERTICAL,'mainBoxDocManagerLayout');
		layout.hgap = 1;
		layout.vgap = 1;

		layout.addLayoutContent(44);
		layout.addLayoutContent(1.0);
		
		var titleAndBack:BoxLayout = new BoxLayout(layout.layoutContents.get(1), DirectionType.HORIZONTAL , 'TitleAndBackBox');
		titleAndBack.hgap = 0;
		titleAndBack.vgap = 0;

		titleAndBack.addLayoutContent(70);
		titleAndBack.addLayoutContent(1.0);

		var btnBack:PngButton = addButon(EVT_BACK_BUTTON, 'btn_left');
		titleAndBack.layoutContents.get(1).setItem(btnBack);
		addChild(btnBack);
		btnBack.addListener(this);

		var lbl:Label = new Label('lblTitleOfDocManager', getPanelTitle(), 0xffffff);
		lbl.setFontSize(32);
		lbl.setFontName(openfl.Assets.getFont("assets/lcd.ttf").fontName);
		lbl.setSizeFill(true);
		lbl.setDrawBorder(0xffffff);
		lbl.setBackgroundColor(0xa1a1a1);
		titleAndBack.layoutContents.get(2).setItem(lbl);
		addChild(lbl);

		clientArea = layout.layoutContents.get(2);
	}

	/**
	* This method handle the creation of new base PngButton for the toolbar
	*
	*/
	private function addButon(name:String, resName:String, ?enabled:Bool = true): PngButton {
		var btn:PngButton = null;
		if (! enabled) {
			btn = new PngButton(
				name, 
				"assets/" + resName + "_cold.png", 
				"assets/" + resName + "_hot.png", 
				"assets/" + resName + "_dis.png"
			);
			btn.setEnable(enabled);
		} else {
			btn = new PngButton(
				name, 
				"assets/" + resName + "_cold.png", 
				"assets/" + resName + "_hot.png"
			);
		}
		return btn;
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic): Void {
		var msg:String = Std.is(sender, PngButton) ? cast(sender, PngButton).name : name;
		switch (msg) {
			case BaseInnerPanel.EVT_BACK_BUTTON:
				app.toggleVisibility(this);
		}
	}

	public function getEventCollection(): Array<String> {
		return [EVT_BACK_BUTTON];	
	}
}