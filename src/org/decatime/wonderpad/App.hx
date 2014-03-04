package org.decatime.wonderpad;

import motion.easing.Quad;
import motion.Actuate;

import flash.geom.Rectangle;

import org.decatime.ui.BaseVisualElement;
import org.decatime.events.IObserver;
import org.decatime.events.IObservable;
import org.decatime.Facade;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.ui.canvas.background.GridBackGround;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import org.decatime.ui.BrowseForFile;
import org.decatime.ui.Label;
import org.decatime.ui.canvas.style.FreeHand;
import org.decatime.ui.MessageDlg;
import org.decatime.ui.canvas.remote.Broadcaster;
import org.decatime.ui.canvas.remote.Server;

class App extends BaseVisualElement implements IObserver {

	public var canvas:DrawingSurface;
	
	private var layout:BoxLayout;
	private var toolbar:MainToolBar;
	private var proToolBar:ProToolBar;
	private var docProperty:PanelDocumentProperty;
	private var pnDocManager:PanelDocManager;
	private var pnProgProperties:PanelProgProperties;
	private var msgDlg:MessageDlg;
	
	public function new() {
		super('WonderPad_1.2.0');
		this.buttonMode = false;

		Facade.getInstance().addListener(this);
		Facade.doLog('in App root container constructor - END', this);
	}

	public override function refresh(r:Rectangle): Void {
		super.refresh(r);
		Facade.doLog('Calling my layout refresh method', this);
		layout.refresh(r);
	}

	public function getPanelDocManager(): PanelDocManager {
		return pnDocManager;
	}

	public function getPanelProgProperties(): PanelProgProperties {
		return pnProgProperties;
	}

	public function notifyClear(): Void {
		#if proversion
		if (Facade.getInstance().getDocManager().getActiveDocument().getCurrPageNum() > 1) {
			msgDlg = Facade.getInstance().showMessage('Delete this page ?', MessageDlg.MESSAGETYPE_QUESTION);
			msgDlg.addListener(this);
			Facade.doLog('Detected clear command on a page that is not the first page. waiting for dlg result', this);
		}
		#end
	}

	public function toggleVisibility(pnToToggle:BaseVisualElement): Void {
		if (canvas.visible) {
			Facade.doLog('the canvas object is going to be hided', this);
			Facade.getInstance().closeAllPopup();
			canvas.visible = false;
			pnToToggle.alpha = 0;
			pnToToggle.visible = true;
			Actuate.tween (pnToToggle, 1, { alpha: 1 } );
			layout.layoutContents.get(1).setVisible(false);
			layout.layoutContents.get(3).setVisible(false);
			Facade.doLog('the canvas object is now unvisible', this);
		} else {
			Facade.doLog('the canvas object is unvisible', this);
			pnToToggle.visible = false;
			canvas.alpha = 0;
			canvas.visible = true;
			Actuate.tween (canvas, 1, { alpha: 1 } );
			layout.layoutContents.get(1).setVisible(true);
			layout.layoutContents.get(3).setVisible(true);
			Facade.doLog('the canvas object is now visible', this);
		}
	}

	private function initializeComponent(): Void {
		initializeLayout();
		Facade.doLog('Creating the canvas object...', this);
		canvas = new DrawingSurface('drawingSurface');
		canvas.addListener(this);
		canvas.setBackground(new GridBackGround(18.86 , 18.86 ));
		layout.layoutContents.get(2).addItem(canvas);//setItem(canvas);
		addChild(canvas);
		Facade.getInstance().setCanvas(canvas);
		Facade.doLog('The canvas object has been created!', this);

		Facade.doLog('Creating the main Tool Bar', this);
		toolbar = new MainToolBar(this, layout.layoutContents.get(1));

		Facade.doLog('registering the windows popup', this);
		registerPopups();

		#if proversion
		Facade.doLog('proversion flag is on. Creating the pro tool bar instance', this);
		proToolBar = new ProToolBar(this, layout.layoutContents.get(3));

		Facade.doLog('Creating the panel for the document manager', this);
		pnDocManager = new PanelDocManager();
		layout.layoutContents.get(2).addItem(pnDocManager);
		addChild(pnDocManager);
		pnDocManager.visible = false;

		Facade.doLog('Creating the panel for wonderpad properties', this);
		pnProgProperties = new PanelProgProperties();
		layout.layoutContents.get(2).addItem(pnProgProperties);
		addChild(pnProgProperties);
		pnProgProperties.visible = false;

		#else
		Facade.doLog('proversion is off. Creating the document property', this);
		docProperty = new PanelDocumentProperty(this, layout.layoutContents.get(3));
		#end

		// // TODO remove me and put me in a window box!!
		#if !flash
		Facade.getInstance().addBroadcaster(new Broadcaster('127.0.0.1',9000));
		// Server.start(canvas, '127.0.0.1', 8181);
		#end
	}

	private function registerPopups(): Void {
		Facade.getInstance().registerWindow(new PopupStyleEditor(canvas));
		Facade.getInstance().registerWindow(new PopupEffectSel(canvas));

		Facade.getInstance().registerWindow(
			new BrowseForFile (
				BrowseForFile.POPUP_NAME, 
				canvas
			)
		);
	}

	private function initializeLayout(): Void {
		Facade.doLog('Initializing the layout - BEGIN', this);
		layout = new BoxLayout(
			this, 
			DirectionType.VERTICAL, 
			'mainApplication_defaultBoxLayout'
		);
		// the application is divided in three parts.
		// the first one is a toolbar with a height of 56
		layout.layoutContents.set(1, new LayoutContent(layout, 56));
		// we dont want to see borders around the layout since 
		// the toolbar will already have one
		layout.layoutContents.get(1).drawBorder = false;

		// the second one will hold the canvas for drawing...
		layout.layoutContents.set(2, new LayoutContent(layout, 1.0));
		//layout.layoutContents.get(2).drawBorder = false;

		// the last one is the document property bar
		layout.layoutContents.set(3, new LayoutContent(layout, 56));
		//layout.layoutContents.get(3).borderColor = 0xffffff;
		//layout.layoutContents.get(3).drawBorder = false;
		Facade.doLog('Initializing the layout - END', this);
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic): Void {
		switch (name) {
			case Facade.EV_INIT:
				Facade.doLog('Init Event from Facade has been received. Calling initializeComponent method...', this);
				initializeComponent();
				
			case DrawingSurface.EVT_DATA_READY:
				Facade.doLog('The event ready state of the DrawingSurface instance has been received. Updating toolbar undo, redo state', this);
				toolbar.updateUndoRedoBtnState();
				if (canvas.getActiveStyle() == null) {
					Facade.doLog('Canvas mode is now NORMAL. Setting the default style for the canvas', this);
					canvas.setActiveStyle(new FreeHand(canvas));
				}
			case MessageDlg.DLG_RESULT:
				if (msgDlg.getDialogResult() == MessageDlg.DLG_RESULT_YES) {
					Facade.getInstance().getDocManager().deletePage(Facade.getInstance().getDocManager().getCurrPageNum());
					proToolBar.updatePaging();
				}
		}
	}

	public function getEventCollection(): Array<String> {
		return [
			Facade.EV_INIT,
			MessageDlg.DLG_RESULT
		];
	}
}