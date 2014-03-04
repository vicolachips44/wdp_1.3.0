package org.decatime.wonderpad;

import flash.display.Sprite;
import flash.Lib;
import flash.utils.ByteArray;

import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.events.IObserver;
import org.decatime.events.IObservable;
import org.decatime.ui.canvas.remote.CmdParser;
import org.decatime.ui.PngButton;
import org.decatime.ui.canvas.remote.RemoteDrawingSurface;
// import org.decatime.ui.BrowseForFile;
import org.decatime.ui.Window;
import org.decatime.Facade;
#if flash
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.net.URLRequestHeader;
#end

class MainToolBar implements IObserver {
	private static var EVT_APP_BTN_UNDO:String = "org.decatime.wonderpad.EVT_APP_BTN_UNDO";
	private static var EVT_APP_BTN_REDO:String = "org.decatime.wonderpad.EVT_APP_BTN_REDO";
	private static var EVT_APP_BTN_STYLE_ED:String = "org.decatime.wonderpad.EVT_APP_BTN_STYLE_ED";
	private static var EVT_APP_BTN_FILTERS:String = "org.decatime.wonderpad.EVT_APP_BTN_FILTERS";
	private static var EVT_APP_BTN_CLEAR:String = "org.decatime.wonderpad.EVT_APP_BTN_CLEAR";
	private static var EVT_APP_BTN_SAVE:String = "org.decatime.wonderpad.EVT_APP_BTN_SAVE";
	//------------------------------------------------------------------------------------
	private var tbarLayout:BoxLayout;
	private var layoutParent:LayoutContent;
	private var app:App;
	private var btnUndo:PngButton;
	private var btnRedo:PngButton;

	public function new(app:App, layoutParent:LayoutContent) {
		this.app = app;
		this.layoutParent = layoutParent;
		createToolbarLayout();
		createToolbarContent();

	}

	private function createToolbarContent(): Void {
		addButon( EVT_APP_BTN_STYLE_ED, 'btn_brushType');
		addButon( EVT_APP_BTN_FILTERS, 'btn_filters');

		btnUndo = addButon( EVT_APP_BTN_UNDO, 'btn_undo', false);
		btnRedo = addButon( EVT_APP_BTN_REDO, 'btn_redo', false);

		addButon( EVT_APP_BTN_CLEAR, 'btn_clear');
		addButon( EVT_APP_BTN_SAVE, 'btn_save');
	}

	private function createToolbarLayout(): Void {
		// The tool bar is belonging to the first layout of the main layout
		// we add an horizontal layout to display buttons
		// A boxlayout can be the child of another boxlayout object
		tbarLayout = new BoxLayout(
			layoutParent, 
			DirectionType.HORIZONTAL, 
			'wonderpadToolBar'
		);

		// a boxlayout object can also have a gradient background
		var spriteBackground:Sprite = new Sprite();
		// we added to this instance of sprite to the app sprite and the layout will do its job.
		app.addChild(spriteBackground);
		tbarLayout.setBackgroundSprite(spriteBackground, 0x0, 0x999999);
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
		var idx:Int = tbarLayout.addLayoutContent(58);

		tbarLayout.layoutContents.get(idx).drawBorder = false;
		tbarLayout.layoutContents.get(idx).setItem(btn);

		btn.addListener(this);
		app.addChild(btn);
		return btn;
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic): Void {
		var msg:String = Std.is(sender, PngButton) ? cast(sender, PngButton).name : name;
		switch(msg) {
			
			case MainToolBar.EVT_APP_BTN_STYLE_ED:
				Facade.getInstance().showPopup(PopupStyleEditor.POPUP_NAME);

			case MainToolBar.EVT_APP_BTN_FILTERS:
				Facade.getInstance().showPopup(PopupEffectSel.POPUP_NAME);

			case MainToolBar.EVT_APP_BTN_CLEAR:
				app.canvas.clear();
				app.notifyClear();
				
			case MainToolBar.EVT_APP_BTN_SAVE:
				#if !flash
				var dirTarget:String = flash.filesystem.File.userDirectory.nativePath;
				var bt:ByteArray = app.canvas.getByteArray('png');
				var flName = Date.now().toString() + "_wonderpad1.png";
				var fullPath:String = dirTarget + Facade.getInstance().getPathSeparator() + flName;
				sys.io.File.saveContent(fullPath, bt.asString());
				Facade.getInstance().showMessage("File has been saved to : " + fullPath);
				#else
				sendImgToBrowser();
				#end
			case MainToolBar.EVT_APP_BTN_UNDO:
				app.canvas.undo();
				updateUndoRedoBtnState();

			case MainToolBar.EVT_APP_BTN_REDO:
				app.canvas.redo();
				updateUndoRedoBtnState();
		}
	}

	private function sendImgToBrowser(): Void {
		//trace ("button save has been clicked...");
		var bt:ByteArray = app.canvas.getByteArray('png');
		var flName:String = "wonderpad1.png";

		var header:flash.net.URLRequestHeader = new
		flash.net.URLRequestHeader("Content-type", "application/octet-stream");
		var endPoint:String = "http://www.decatime.org/wp1/";
		var myRequest:flash.net.URLRequest = new flash.net.URLRequest(endPoint + "image.php?name="+flName);
		myRequest.requestHeaders.push(header);
		myRequest.method = flash.net.URLRequestMethod.POST;
		myRequest.data = bt;
		flash.Lib.getURL(myRequest, "_blank");
	}

	public function getEventCollection(): Array<String> {
		return [
			PngButton.EVT_PNGBUTTON_CLICK
		];
	}

	public function updateUndoRedoBtnState(): Void {
		 var canRedo:Bool = app.canvas.getUndoRedoManager().canRedo();
		btnRedo.setEnable(canRedo);

		var canUndo:Bool = app.canvas.getUndoRedoManager().canUndo();
		btnUndo.setEnable(canUndo);
	}
}