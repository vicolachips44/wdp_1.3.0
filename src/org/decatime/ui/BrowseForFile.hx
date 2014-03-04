package org.decatime.ui;

import openfl.Assets;

import flash.filesystem.File;

import flash.geom.Rectangle;
import flash.geom.Point;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import org.decatime.Facade;

import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;

import org.decatime.events.IObserver;
import org.decatime.events.IObservable;
import org.decatime.events.EventManager;

import org.decatime.ui.ShapeButton;
import org.decatime.ui.canvas.DocManager;

class BrowseForFile extends Window implements IObservable {
	public static inline var EVT_FILE_SELECTION:String = NAMESPACE + "EVT_FILE_SELECTION";

	public static inline var POPUP_NAME:String = 'BrowseForFile';

	private static inline var NAMESPACE = "org.decatime.display.ui.BrowseForFile: ";

	public static var MODE_OPEN:String = "mode_open";
	public static var MODE_SAVE:String = "mode_save";

	private static var BMUP:String = "bitmapNavUp";
	private var evManager:EventManager;
	private var vscrollBar:VerticalScrollBar;
	private var bfileList:BrowseForFileList;
	private var modeOpenPanel:BaseVisualElement;
	private var modeSavePanel:BaseVisualElement;

	private var layoutCurrPathValue:LayoutContent;
	private var layoutList:LayoutContent;
	private var layoutBottom:LayoutContent;
	private var layoutListItem:LayoutContent;
	private var layoutScBar:LayoutContent;
	private var layoutUpIcon:LayoutContent;
	private var lblCurrPath:Label;
	private var bmUp:BaseBmpElement;
	private var modeType:String;
	private var rootPath:String;
	private var panelButton:BaseVisualElement;
	private var lblFileName:Label;
	private var txtFileName:TextBox;
	private var btnOp:SimpleButton;
    private var pathSeparator:String;

	public function new(title:String, owner:IVisualElement, ?modeType:String, ?rootPath:String) {
		super(POPUP_NAME, title, owner);
		this.position = new Rectangle(0, 0, 460, 380); // 372
		this.evManager = new EventManager(this);
		this.bmUp = new BaseBmpElement(Assets.getBitmapData("assets/decatime_nav_up.png"));
		this.bmUp.name = BMUP;
		this.bmUp.setGaps(0, 4);
		if (modeType == null) {
			this.modeType = MODE_OPEN;
		} else {
			this.modeType = modeType;
		}

		if (rootPath == null) {
			this.rootPath = File.userDirectory.nativePath;
		} else {
			this.rootPath = rootPath;
		}
        pathSeparator = Facade.getInstance().getPathSeparator();
	}

	public function setFileFilter(value:Array<String>): Void {
		bfileList.setFileFilter(value);
	}

	public override function isModal(): Bool {
		return true;
	}

	public function getMode(): String {
		return this.modeType;
	}

	public function setMode(value:String): Void {
		btnOp.removeEventListener(MouseEvent.CLICK, onBtnClick);
		panelButton.removeChild(btnOp);
		btnOp = null;
		this.modeType  = value;

		if (this.modeType == MODE_OPEN) {
			lblFileName.visible = false;
			txtFileName.visible = false;
			//btnOp = getButton('Open');
			btnOp = ButtonFactory.getButton('Open');
			btnOp.addEventListener(MouseEvent.CLICK, onBtnClick);
			panelButton.addChild(btnOp);

		} else {
			lblFileName.visible = true;
			txtFileName.visible = true;
			//btnOp = getButton('Save');
			btnOp = ButtonFactory.getButton('Save');
			btnOp.addEventListener(MouseEvent.CLICK, onBtnClick);
			panelButton.addChild(btnOp);
		}
	}

	public function getRootPath(): String {
		return this.rootPath;
	}

	private override function createClientArea(clientArea:LayoutContent): Void {
		// create layout
		createMyLayout(clientArea); // cannot use createLayout since it is a based method...
	}

	private override function updateProperties(): Void {
		bfileList.reload();
	}

	private override function initializeComponent(r:Rectangle): Void {
		bfileList = new BrowseForFileList(rootPath, layoutListItem, onBuildListEnded);
		this.addChild(bfileList.list);

		vscrollBar = new VerticalScrollBar('myVerticalScrollBar', layoutScBar, bfileList);
		this.addChild(vscrollBar);

		lblCurrPath = new Label('lblCurrPath', rootPath, 0x000000);
		lblCurrPath.x = 0;
		lblCurrPath.width = 460;
		lblCurrPath.textColor = 0x00ddff;
		lblCurrPath.setFontSize(12);
		lblCurrPath.autoSize = flash.text.TextFieldAutoSize.NONE;
		layoutCurrPathValue.setItem(lblCurrPath);
		this.addChild(lblCurrPath);

		layoutUpIcon.setItem(bmUp);
		this.addChild(bmUp);

		this.addEventListener(MouseEvent.CLICK, onMeClick);
		buildFileOp();
		
		if( this.modeType == MODE_SAVE) {
			flash.Lib.stage.focus = txtFileName;
		}
	}

	private function buildFileOp(): Void {
		var hboxFileOp:BoxLayout = new BoxLayout(layoutBottom, DirectionType.HORIZONTAL,'hboxFileOp');

		hboxFileOp.vgap = 10;
		hboxFileOp.hgap = 0;

		lblFileName = new Label('lblFileName','File name:', 0x000000);
		lblFileName.setWidth(100);
		lblFileName.setMargins(new flash.geom.Point(0, 9));
		hboxFileOp.layoutContents.get(hboxFileOp.addLayoutContent(100)).setItem(lblFileName);
		this.addChild(lblFileName);

		txtFileName = new TextBox('txtFileName', ' ');
		txtFileName.setMargins(new flash.geom.Point(0, 9));
		hboxFileOp.layoutContents.get(hboxFileOp.addLayoutContent(150)).setItem(txtFileName);
		this.addChild(txtFileName);

		panelButton = new BaseVisualElement("panelButton");
		panelButton.isContainer = false;
		hboxFileOp.layoutContents.get(hboxFileOp.addLayoutContent(140)).setItem(panelButton);

		btnOp = ButtonFactory.getButton('Open');
		panelButton.addChild(btnOp);
		this.addChild(panelButton);

		btnOp.addEventListener(MouseEvent.CLICK, onBtnClick);
	}

	private function onBtnClick(e:MouseEvent): Void {
		var fileFullPath:String = bfileList.getSelectedPath();
		if (fileFullPath == null) {
			trace ("WARNING: the current selected path is null...");
			return;
		}

		if (sys.FileSystem.isDirectory(fileFullPath) && modeType == MODE_OPEN) {
			bfileList.setCurrPath(fileFullPath);
			bfileList.reload();
		} else if (sys.FileSystem.isDirectory(fileFullPath) && modeType == MODE_SAVE) {
			fileFullPath = fileFullPath + Facade.getInstance().getPathSeparator() + StringTools.trim(txtFileName.text) + "." + DocManager.FILE_EXT;
			evManager.notify(EVT_FILE_SELECTION, fileFullPath);
			this.close();
		} else {
			evManager.notify(EVT_FILE_SELECTION, fileFullPath);
			this.close();
		}
	}

	private function buildModeSaveComp(): Void {
		var hboxSave:BoxLayout = new BoxLayout(layoutBottom, DirectionType.HORIZONTAL,'hboxSave');
		hboxSave.vgap = 10;
		hboxSave.addLayoutContent(1.0); // align to right
		hboxSave.addLayoutContent(140); // lblFileName
		hboxSave.addLayoutContent(150); // txtFileName
		hboxSave.addLayoutContent(140); // btnSave
		hboxSave.addLayoutContent(20); // space right
		
		var btn:SimpleButton = ButtonFactory.getButton('Save');

		modeSavePanel = new BaseVisualElement("modeSavePanel");
		modeSavePanel.isContainer = false;
		hboxSave.layoutContents.get(3).setItem(modeSavePanel);
	}

	private function onMeClick(e:MouseEvent): Void {
		var objs:Array<DisplayObject> = this.getObjectsUnderPoint(new Point(e.stageX, e.stageY));
		if (objs.length == 2 && Std.is(objs[1], Bitmap) && objs[1].name == BMUP) {
			var lpath:String = lblCurrPath.text.substr(0, lblCurrPath.text.lastIndexOf(pathSeparator));
            //trace ("current lpath value is " + lpath);
			if (lpath == "" && pathSeparator == "/") { lpath = pathSeparator; }
            if (lpath.length == 1 && pathSeparator == "\\") { 
                lpath += ":"; 
                this.bfileList.loadWinDrives();
            } else {
                this.bfileList.setCurrPath(lpath);
                this.bfileList.reload();
            }
		}
	}

	private function onBuildListEnded(): Void {
		lblCurrPath.text = bfileList.getCurrPath();
		
		vscrollBar.synchronize();
	}

	private function createMyLayout(clientArea:LayoutContent): Void {
		var mainBox:BoxLayout = new BoxLayout(clientArea, DirectionType.VERTICAL ,'mainBox');

		mainBox.hgap = 2;
		mainBox.vgap = 2;

		var hboxPath:BoxLayout = new BoxLayout(
			mainBox.layoutContents.get(mainBox.addLayoutContent(40)), 
			DirectionType.HORIZONTAL, 
			'hlistPath'
		);
		hboxPath.hgap = 1;
		hboxPath.vgap = 1;

		layoutCurrPathValue = hboxPath.layoutContents.get(hboxPath.addLayoutContent(410));
		hboxPath.addLayoutContent(14); // spacer
		layoutUpIcon = hboxPath.layoutContents.get(hboxPath.addLayoutContent(1.0));

		layoutList = mainBox.layoutContents.get(mainBox.addLayoutContent(214));
		layoutBottom = mainBox.layoutContents.get(mainBox.addLayoutContent(80));

		var hboxList:BoxLayout = new BoxLayout(layoutList, DirectionType.HORIZONTAL , 'hboxList');
		hboxList.hgap = 0;
		hboxList.vgap = 0;
		layoutListItem = hboxList.layoutContents.get(hboxList.addLayoutContent(1.0));
		layoutScBar = hboxList.layoutContents.get(hboxList.addLayoutContent(23));
	}

	// IObservable implementation
	public function addListener(observer:IObserver): Void {
		this.evManager.addListener(observer);
	}
	public function removeListener(observer:IObserver): Void {
		this.evManager.removeListener(observer);
	}

	public function notify(name:String, data:Dynamic): Void {
		this.evManager.notify(name, data);
	}
	// IObservable implementation END
}