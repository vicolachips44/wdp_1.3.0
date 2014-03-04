package org.decatime.ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.display.GradientType;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.geom.Point;

import openfl.Assets;
import flash.filesystem.StorageVolume;
import flash.filesystem.StorageVolumeInfo;

import org.decatime.layouts.LayoutContent;

class BrowseForFileList implements IVisualElement {
	private var sizeInfo:Rectangle;
	private var currPath:String;
	private var selectedPath:String;
	private var parentLayout:LayoutContent;
	private var name:String;
	private var visible:Bool;
	private var listItemHeight:Int;
	private var firstVisible:Int;
	private var nbVisible:Int;
	private var listCount:Int;
    private var pathSeparator:String;
	private var bmpDirectory:BitmapData;
	private var bmpFile:BitmapData;
	private var selectedItem:Bitmap;
	private var buildEndCallback:Void->Void;
	private var filterFiles:Array<String>;
	private var fileFilter:Array<String>;

	public var list:Sprite;

	public function new(initialPath:String, parentLayout:LayoutContent, buildEndCallback:Void->Void) {
		this.currPath = initialPath;
		this.selectedPath = initialPath;
		this.parentLayout = parentLayout;
		this.parentLayout.setItem(this);
		this.name = "BrowseForFileList";
		list = new Sprite();
		list.addEventListener(MouseEvent.MOUSE_DOWN, onListMouseDown);
		listItemHeight = 24;
		firstVisible = 0;
		bmpDirectory = Assets.getBitmapData("assets/directory.png");
		bmpFile = Assets.getBitmapData("assets/file.png");
		this.buildEndCallback = buildEndCallback;
		fileFilter = new Array<String>();
        //trace ("system name is " + Sys.systemName());
        pathSeparator = Facade.getInstance().getPathSeparator();
	}

	public function getCurrPath(): String {
		return currPath;
	}

	public function setCurrPath(value:String): Void {
		firstVisible = 0;
		currPath = value;
	}

	public function getSelectedPath(): String {
		return selectedPath;
	}

	public function setFileFilter(value:Array<String>): Void {
		this.fileFilter = value;
	}

	public function getListItemHeight(): Int {
		return this.listItemHeight;
	}

	public function getNbVisible(): Int {
		return this.nbVisible;
	}

	public function getFirstVisible(): Int {
		return this.firstVisible;
	}

	public function setFirstVisible(value:Int, ?update:Bool = true): Void {
		this.firstVisible = value;
		
		reload(update);
	}

	public function getListCount(): Int {
		return this.listCount;
	}

	// IVisualElement implementation
	public function refresh(r:Rectangle): Void {
		this.sizeInfo = r;
		refreshListContainer(r);
	}

	public function reload(?update:Bool = true): Void {
		if (this.getInitialSize() == null) {
			throw "my size has not been initialized can't redraw";
		}
		buildList(this.getInitialSize(), update);
	}
    
    /**
     * Called when the path separator is a window path seperator
     * Will build the list of available drives.
     */
    public function loadWinDrives(): Void {
        updateVisibleElCount(sizeInfo);
		clearList();
		list.graphics.clear();
		refreshListContainer(sizeInfo);
        currPath = "";
        var volumes:Array<StorageVolume> = StorageVolumeInfo.getInstance().getStorageVolumes();
        var volume:StorageVolume = null;
        var currY:Float = 0;
        for (volume in volumes) {
            paintAsDirectory(
                volume.drive, 
                new Rectangle(0, 0, sizeInfo.width, this.listItemHeight), 
                new Point(0, currY)
            );
            currY += this.listItemHeight;
        }
    }

	private function buildList(r:Rectangle, ?update:Bool = true): Void {
		updateVisibleElCount(r);
		clearList();
		list.graphics.clear();
		refreshListContainer(sizeInfo);
		if (filterFiles == null || update) {
            //trace ("currPath value is " + currPath);
			var files:Array<String> = sys.FileSystem.readDirectory(currPath);
			filterFiles = sortAndFilter(files);
			listCount = filterFiles.length;
		}

		var currY:Float = 0;

		for (i in firstVisible...nbVisible + firstVisible) {
			if (i > filterFiles.length - 1) {
				break; // no more items
			}
			var file:String = filterFiles[i];

			var lpath:String = file.substr(0, 1) == pathSeparator ? file : currPath + pathSeparator + file;

			if (sys.FileSystem.isDirectory(lpath)) {
				paintAsDirectory(
					file, 
					new Rectangle(0, 0, r.width, this.listItemHeight), 
					new Point(0, currY)
				);
			} else {
				paintAsFile(
					file, 
					new Rectangle(0, 0, r.width, this.listItemHeight), 
					new Point(0, currY)
				);
			}

			currY += this.listItemHeight;
		}
		if (update) {
			this.buildEndCallback();	
		}
	}

	private function clearList(): Void {
		if (this.list.numChildren == 0) { 
			//trace ("no children in my list");
			return; 
		}
		while (this.list.numChildren > 0) {
			this.list.removeChildAt(0);
		}
	}

	private function paintAsDirectory(name:String, r:Rectangle, p:Point): Void {
		var bmContainer:Sprite = new Sprite();
		var bmpDir = new Bitmap(bmpDirectory);
		bmpDir.x = 2;
		bmpDir.y = p.y + 4;

		bmContainer.addChild(bmpDir);

		var bm:Bitmap = BitmapText.getNew(
			new Rectangle(0, 0, r.width - 20, r.height), 
			new Point(p.x + 18, p.y), 
			name, 
			0x0000ff
		);
		
		bmContainer.buttonMode = true;
		bmContainer.doubleClickEnabled = true;
		bmContainer.addChild(bm);

		this.list.addChild(bmContainer);
		bmContainer.addEventListener(MouseEvent.DOUBLE_CLICK, onListItemDbClick);
	}

	private function onListMouseDown(e:MouseEvent): Void {
		var objs:Array<DisplayObject> = list.getObjectsUnderPoint(new Point(e.stageX, e.stageY));
		if (objs.length == 2) {
			if (Std.is(objs[1], Bitmap)) {
				//trace ("drawing ");
				var g:Graphics = list.graphics;
				g.clear();
				refreshListContainer(this.sizeInfo);
				g.lineStyle(0.5, 0xffffff, 0.8);
				var box:Matrix = new Matrix();
				box.createGradientBox( objs[1].width , objs[1].height);
				g.beginGradientFill(GradientType.LINEAR, [0xffd801, 0xffa102], [1, 0.6], [1, 255], box);
				g.drawRect(objs[1].x, objs[1].y, objs[1].width, objs[1].height);
				g.endFill();
				selectedItem = cast(objs[1], Bitmap);
				selectedPath = currPath + pathSeparator + selectedItem.name;
			}
			
		}
	}

	private function onListItemDbClick(e:MouseEvent): Void {
		var sp:Sprite = cast(e.currentTarget, Sprite);
		sp.removeEventListener(MouseEvent.DOUBLE_CLICK, onListItemDbClick);
		firstVisible = 0;
		filterFiles = null;
		var bm:Bitmap = cast (sp.getChildAt(1), Bitmap);
        var path:String = bm.name;
        if (currPath.length > 0 && currPath.substr(currPath.length - 1, 1) != pathSeparator) {
            //path = currPath == pathSeparator ? currPath + bm.name : currPath + pathSeparator + bm.name;
            path = currPath + pathSeparator + bm.name;
        } else {
            path = currPath + bm.name;
        }
		//trace ("double clicked path is " + path);
		if (sys.FileSystem.isDirectory(path)) {
			currPath = path;
			buildList(this.sizeInfo);
		}
	}

	private function paintAsFile(name:String, r:Rectangle, p:Point): Void {
		var bmFile = new Bitmap(bmpFile);
		bmFile.x = 2;
		bmFile.y = p.y + 4;
		this.list.addChild(bmFile);

		var bm:Bitmap = BitmapText.getNew(
			new Rectangle(0, 0, r.width - 20, r.height), 
			new Point(p.x + 18, p.y), 
			name
		);
		this.list.addChild(bm);
	}

	private function isFileBelongsToFilter(file:String): Null<String> {
		if (fileFilter.length == 0) { return file; }
		var bInFilter:Bool = false;

		for (filter in fileFilter) {
			if (file.lastIndexOf(filter, file.length -4) > -1) {
				bInFilter = true;
				break;
			}
		}
		return bInFilter ? file: null;
	}

	private function sortAndFilter(files:Array<String>): Array<String> {
		var retValue:Array<String> = new Array<String>();
		var filter:String = "";
		var file:String = "";

		for (file in files) {
			if (file.substr(0, 1) == ".") { continue; } // hiden file

			var isDirectory = sys.FileSystem.isDirectory(currPath + pathSeparator + file);

			if (isDirectory == false && isFileBelongsToFilter(file) == null) {
				continue; // the file extension is not in the list of filters extension
			}
			retValue.push(file);	
		}

		retValue.sort( function(a:String, b:String):Int
		{
		    a = a.toLowerCase();
		    b = b.toLowerCase();
		    if (a < b) return -1;
		    if (a > b) return 1;
		    return 0;
		} );
		return retValue;
	}

	private function updateVisibleElCount(r:Rectangle): Void {
		var nbElement:Float = r.height / this.listItemHeight;
		nbVisible = Math.round(nbElement);
	}

	private function refreshListContainer(r:Rectangle): Void {
		list.x = r.x;
		list.y = r.y;
		list.graphics.beginFill(0xe1e1e1, 1);
		list.graphics.lineStyle(3, 0xa1a1a1);
		list.graphics.drawRect(0, 0, r.width, r.height);

		list.graphics.endFill();
	}
	
	public function getDrawingSurface(): Graphics {
		return null;
	}

	public function getInitialSize(): Rectangle {
		return sizeInfo;
	}

	public function getId(): String {
		return name;
	}

	public function setVisible(value:Bool): Void {
		this.list.visible = value;
	}
	// IVisualElement implementation - END
}