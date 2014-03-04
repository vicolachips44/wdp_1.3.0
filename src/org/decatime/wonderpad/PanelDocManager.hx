package org.decatime.wonderpad;

import flash.geom.Rectangle;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;


import org.decatime.ui.BaseVisualElement;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.layouts.LayoutContent;
import org.decatime.ui.Label;
import org.decatime.ui.PngButton;
import org.decatime.ui.ButtonFactory;

import org.decatime.Facade;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.ui.BrowseForFile;
import org.decatime.ui.Window;
import org.decatime.ui.canvas.DocManager;

class PanelDocManager extends BaseInnerPanel {

	private var lblActiveDocInfo:Label;

	public function new() {
		super();
	}

	private override function getPanelTitle():String {
		return 'Document Manager';
	}

	private override function initLayout(): Void {
		super.initLayout();
		Facade.doLog('In initLayout method - BEGIN', this);
		var boxActiveDoc:BoxLayout = new BoxLayout(clientArea, DirectionType.VERTICAL, 'boxActiveDoc');

		lblActiveDocInfo = new Label('lblActiveDocInfo', 'Active document path: Unsaved', 0x000000);
		lblActiveDocInfo.setSizeFill(true);
		boxActiveDoc.layoutContents.get(boxActiveDoc.addLayoutContent(48)).setItem(lblActiveDocInfo);
		boxActiveDoc.layoutContents.get(1).drawBorder = false;
		addChild(lblActiveDocInfo);

		
		var btnOpen:BaseVisualElement = new BaseVisualElement('btnOpenContainer');
		btnOpen.isContainer = false;
		
		boxActiveDoc.layoutContents.get(boxActiveDoc.addLayoutContent(48)).setItem(btnOpen);
		boxActiveDoc.layoutContents.get(2).drawBorder = false;

		addChild(btnOpen);
		var btn:SimpleButton = ButtonFactory.getButton('Open...');
		btnOpen.addChild(btn);

		btnOpen.addEventListener(MouseEvent.CLICK, onBtnOpenClick);

		var btnSave:BaseVisualElement = new BaseVisualElement('btnSaveContainer');
		btnSave.isContainer = false;
		
		boxActiveDoc.layoutContents.get(boxActiveDoc.addLayoutContent(48)).setItem(btnSave);
		boxActiveDoc.layoutContents.get(3).drawBorder = false;

		addChild(btnSave);
		btn = ButtonFactory.getButton('Save');
		btnSave.addChild(btn);

		btnSave.addEventListener(MouseEvent.CLICK, onBtnSaveClick);

		var btnSaveAs:BaseVisualElement = new BaseVisualElement('btnSaveAsContainer');
		btnSaveAs.isContainer = false;
		
		boxActiveDoc.layoutContents.get(boxActiveDoc.addLayoutContent(48)).setItem(btnSaveAs);
		boxActiveDoc.layoutContents.get(4).drawBorder = false;

		addChild(btnSaveAs);
		btn = ButtonFactory.getButton('Save As...');
		btnSaveAs.addChild(btn);

		btnSaveAs.addEventListener(MouseEvent.CLICK, onBtnSaveAsClick);
		Facade.getInstance().getDocManager().addListener(this);
		Facade.doLog('I am now listening to the documentManager instance events', this);
	}

	private function onBtnSaveAsClick(e:MouseEvent): Void {
		var w:Window = Facade.getInstance().getWindowByName(BrowseForFile.POPUP_NAME);

		if (w != null) {
			var bf:BrowseForFile = cast(w, BrowseForFile);
			Facade.getInstance().showPopup(BrowseForFile.POPUP_NAME);
			bf.setMode(BrowseForFile.MODE_SAVE);
			bf.addListener(this);
		} 
	}

	private function onBtnSaveClick(e:MouseEvent): Void {
		var mn:DocManager = Facade.getInstance().getDocManager();

		var pathOfDoc:String = mn.getActiveDocument().getPath();
		if (pathOfDoc != "") {
			mn.saveActiveDocument(pathOfDoc);
		} else {
			onBtnSaveAsClick(e);
		}
	}

	private function onBtnOpenClick(e:MouseEvent): Void {
		Facade.doLog('onBtnOpenClick: Btn open has been clicked. Showing BrowseForFile in open mode', this);
		var w:Window = Facade.getInstance().getWindowByName(BrowseForFile.POPUP_NAME);
		if (w != null) {
			var bf:BrowseForFile = cast(w, BrowseForFile);
			Facade.getInstance().showPopup(BrowseForFile.POPUP_NAME);
			bf.setMode(BrowseForFile.MODE_OPEN);
			bf.addListener(this);
			bf.setFileFilter(['.wdp']);
			Facade.doLog('onBtnOpenClick: the file filter has been setted to .wdp', this);
		} 
	}

	public override function handleEvent(name:String, sender:IObservable, data:Dynamic): Void {
		super.handleEvent(name, sender, data);
		switch (name) {
		case BrowseForFile.EVT_FILE_SELECTION:
			Facade.doLog('handleEvent: The event file selection has been received', this);
			var w:Window = Facade.getInstance().getWindowByName(BrowseForFile.POPUP_NAME);
			if (w != null) {
				var bf:BrowseForFile = cast(w, BrowseForFile);
				bf.removeListener(this);
				if (bf.getMode() == BrowseForFile.MODE_OPEN) {
					Facade.doLog('handleEvent: Calling the loadFile method of DocManager object', this);
					Facade.getInstance().getDocManager().loadFile(data);
					Facade.doLog('handleEvent: The document should be loaded', this);
				} else {
					Facade.doLog('handleEvent: Calling the saveActiveDocument method of DocManager object', this);
					Facade.getInstance().getDocManager().saveActiveDocument(data);
					Facade.doLog('handleEvent: The active document has been saved', this);
				}
			}
		case DocManager.EVT_NEW_DOCUMENT_LOADED | DocManager.EVT_DOC_SAVED:
			Facade.doLog('handleEvent: Received load or saved new document event. Updating label status', this);
			lblActiveDocInfo.setLabel("Active document path: " + data);
		}
	}

	public override function getEventCollection(): Array<String> {
		return super.getEventCollection().concat(
			[
				BrowseForFile.EVT_FILE_SELECTION,
				DocManager.EVT_NEW_DOCUMENT_LOADED,
				DocManager.EVT_DOC_SAVED
			]	
		);
	}
}