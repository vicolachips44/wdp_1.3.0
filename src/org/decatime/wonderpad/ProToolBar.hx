package org.decatime.wonderpad;

import flash.display.Sprite;

import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.events.IObserver;
import org.decatime.events.IObservable;
import org.decatime.ui.Label;
import org.decatime.ui.PngButton;
import org.decatime.ui.canvas.DocManager;
import org.decatime.ui.BrowseForFile;
import org.decatime.ui.Window;
import org.decatime.Facade;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.ui.MessageDlg;

class ProToolBar implements IObserver {
	private static var EVT_PAGE_BTN_ADD:String = "org.decatime.wonderpad.EVT_PAGE_BTN_ADD";
	private static var EVT_PAGE_BTN_NEXT:String = "org.decatime.wonderpad.EVT_PAGE_BTN_NEXT";
	private static var EVT_PAGE_BTN_PREVIOUS:String = "org.decatime.wonderpad.EVT_PAGE_BTN_PREVIOUS";
	private static var EVT_DOC_BTN_CLICK:String = "org.decatime.wonderpad.EVT_DOC_BTN_CLICK";
	private static var EVT_BTN_SETUP:String = "org.decatime.wonderpad.EVT_BTN_CONF";

	private var tbarLayout:BoxLayout;
	private var layoutParent:LayoutContent;
	private var app:App;
	private var lblPaging:Label;
	private var docManager:DocManager;

	public function new(app:App, layoutParent:LayoutContent) {
		this.app = app;
		this.layoutParent = layoutParent;
		createToolbarLayout();
		createToolbarContent();

	}

	private function createToolbarLayout(): Void {
		tbarLayout = new BoxLayout(
			layoutParent, 
			DirectionType.HORIZONTAL, 
			'wonderpadProToolBar'
		);

		var spriteBackground:Sprite = new Sprite();
		app.addChild(spriteBackground);
		tbarLayout.setBackgroundSprite(spriteBackground, 0x0, 0x999999);
		tbarLayout.addLayoutContent(0.5);
	}

	private function createToolbarContent(): Void {
		addButon(EVT_BTN_SETUP, 'btn_setup');
		addButon(EVT_DOC_BTN_CLICK, 'btn_doc');
		addButon(EVT_PAGE_BTN_PREVIOUS, 'btn_left');
		addDocPaging();
		addButon(EVT_PAGE_BTN_NEXT, 'btn_right');
		addButon( EVT_PAGE_BTN_ADD, 'btn_add');
		tbarLayout.addLayoutContent(0.5);
	}

	private function addDocPaging(): Void {
		var idx:Int = tbarLayout.addLayoutContent(100);
		var blayout:BoxLayout = new BoxLayout( 
			tbarLayout.layoutContents.get(idx), 
			DirectionType.VERTICAL, 
			'bspacer'
		);
		blayout.hgap = 0;
		blayout.vgap = 0;
		blayout.addLayoutContent(14);
		idx = blayout.addLayoutContent(1.0);

		docManager = Facade.getInstance().getDocManager();

		var currPage:Int = docManager.getCurrPageNum();
		var pageCount:Int = docManager.getPageCount();

		lblPaging = new Label('lblPaging', currPage + '/' + pageCount);
		lblPaging.setFontSize(16);
		lblPaging.setWidth(100);
		app.addChild(lblPaging);

		blayout.layoutContents.get(idx).setItem(lblPaging);

		docManager.addListener(this);
		app.canvas.addListener(this);
	}

	public function updatePaging(): Void {
		var currPage:Int = docManager.getCurrPageNum();
		var pageCount:Int = docManager.getPageCount();
		lblPaging.setLabel(currPage + '/' + pageCount);
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
		switch (msg) {
			case Facade.EV_READY:
				docManager.addListener(this);
				updatePaging();

			case ProToolBar.EVT_DOC_BTN_CLICK:
				app.toggleVisibility(app.getPanelDocManager());
				
			case ProToolBar.EVT_PAGE_BTN_ADD:
			docManager.newPage();
			updatePaging();

			case ProToolBar.EVT_PAGE_BTN_PREVIOUS:
			if (docManager.canGoPrevious()) {
				docManager.movePrevious();
				updatePaging();
			}

			case ProToolBar.EVT_PAGE_BTN_NEXT:
			if (docManager.canGoNext()) {
				docManager.moveNext();
				updatePaging();
			}

			case DocManager.EVT_NEW_DOCUMENT_LOADED:
				Facade.doLog("Event new document loaded catched. Updating the paging display", this);
				updatePaging();

			case ProToolBar.EVT_BTN_SETUP:
				app.toggleVisibility(app.getPanelProgProperties());

		}
	}

	public function getEventCollection(): Array<String> {
		return [
			PngButton.EVT_PNGBUTTON_CLICK,
			DocManager.EVT_NEW_DOCUMENT_LOADED,
			Facade.EV_READY
		];
	}
}