/* 
 * Copyright (C)2012-2013 decatime.org
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a 
 * copy of this software and associated documentation files (the "Software"), 
 * to deal in the Software without restriction, including without limitation 
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 * and/or sell copies of the Software, and to permit persons to whom the 
 * Software is furnished to do so, subject to the following conditions: 
 * 
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software. 
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE. 
 */
 
package  org.decatime.ui.canvas.remote;

import flash.display.Graphics; 
import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flash.display.PixelSnapping;
import flash.geom.Rectangle;

import org.decatime.ui.IVisualElement;
import org.decatime.ui.canvas.background.BaseBackGround;
import org.decatime.ui.canvas.style.IDrawable;
import org.decatime.ui.canvas.style.FreeHand;
import org.decatime.ui.canvas.style.TextStyle;

class RemoteDrawingSurface extends Sprite implements IVisualElement {
	public static var MODE_NORMAL:String = "MODE_NORMAL";
	public static var MODE_LOADING:String = "MODE_LOADING";

	private var sizeInfo:Rectangle;
	private var activeStyle:IDrawable;
	private var previousStyle:IDrawable;
	private var bmdCache:BitmapData;
	private var bmCache:Bitmap;
	private var drawingFeedback:Shape;
	private var canDraw:Bool;
	private var hasChanged:Bool;
	private var undoRedoManager:UndoRedoManager;
	private var filterAy:Array<BitmapFilter>;
	private var filterHasChange:Bool;
	private var backGround:BaseBackGround;
	private var startx:Float;
	private var starty:Float;
	private var lastSize:Rectangle;
	private var mode:String;

	public function new(in_name:String) {
		super();
		
		name = in_name;

		canDraw = false;
		hasChanged = false;
		filterHasChange = false;
		mode = MODE_NORMAL;

		filterAy = new Array<BitmapFilter>();

		undoRedoManager = new UndoRedoManager(bmdCache);
		undoRedoManager.setUndoLevel(32);

		startx = -1.0;
		starty = -1.0;
		addEventListener(Event.ADDED_TO_STAGE, onCanvasAddedToStage);
	}

	public function setMode(modeValue:String): Void {
		mode = modeValue;
		Facade.doLog("Instance is in " + mode + ' now', this);
	}

	public function getMode(): String {
		return mode;
	}

	public function undo(): Void {
		
		undoRedoManager.undo();
		
	}

	public function redo(): Void {
		
		undoRedoManager.redo();
		
	}

	public function getActiveFilterAy(): Array<BitmapFilter> {
		return filterAy;
	}

	public function initFilterAy(): Void {
		filterAy = new Array<BitmapFilter>();
	}

	public function addFilter(filter:BitmapFilter): Void {
		filterAy.push(filter);
		Facade.doLog("the filter array has been modified", this);
	}

	public function removeFilter(filter:BitmapFilter): Void {
		filterAy.remove(filter);
	}

	public function hasFilter(filter:BitmapFilter): Bool {
		var ft:BitmapFilter = null;
		for (ft in filterAy) {
			if (ft == filter) {
				return true;
			}
		}
		return false;
	}

	public function setActiveStyle(sty:IDrawable): Void {
		
		if (activeStyle != null) { activeStyle.cleanUp(); }
		activeStyle = sty;
		
	}

	public function getActiveStyle():IDrawable {
		
		return activeStyle;
		
	}

	public function setUndoLevel(value:Int): Void {
		
		undoRedoManager.setUndoLevel(value);
		
	}

	public function getUndoRedoManager(): UndoRedoManager {
		
		return undoRedoManager;
		
	}

	public function setBackground(bg:BaseBackGround): Void {
		
		backGround = bg;
		
	}

	private function onCanvasAddedToStage(e:Event): Void {
		
		removeEventListener(Event.ADDED_TO_STAGE, onCanvasAddedToStage);

		// creates the drawing feedback shape
		drawingFeedback = new Shape();
		//drawingFeedback.cacheAsBitmap = true;
		drawingFeedback.addEventListener(Event.ADDED_TO_STAGE, onFeedbackAddedToStage);
		addChild(drawingFeedback);
		
	}

	private function onFeedbackAddedToStage(e:Event): Void {
		drawingFeedback.removeEventListener(Event.ADDED_TO_STAGE, onFeedbackAddedToStage);
	}

	public function processDown(xpos:Float, ypos:Float): Void {
		
		if (activeStyle == null) { 
			
			return; 
		}

		startx = xpos - x;
		starty = ypos - y;

		activeStyle.prepare(drawingFeedback.graphics, startx, starty);

		if (mode == MODE_NORMAL) {
			this.setChildIndex(drawingFeedback, numChildren - 1);
		}
		drawingFeedback.filters = filterAy;
		Facade.doLog('ProcessDown end function. Filters are now setted with number of active filters: ' + filterAy.length, this);
		canDraw = true;
		
	}

	public function processMove(xpos:Float, ypos:Float): Void {
		
		if (! canDraw) {
			
			return; 
		}

		activeStyle.draw(drawingFeedback.graphics, xpos - x, ypos - y);
		hasChanged = true;
		
		
	}

	public function processEnd(xpos:Float, ypos:Float): Void {
		
		canDraw = false;
		
		activeStyle.finalize( drawingFeedback.graphics, xpos - x, ypos - y);
		storeData();

		hasChanged = false;
		
	}

	public function getBmdCache(): BitmapData {
		return bmdCache;
	}

	public function getBmCache(): Bitmap {
		return bmCache;
	}

	private function storeData(): Void {
		bmdCache.draw(drawingFeedback);   // cache data
		drawingFeedback.graphics.clear(); // clear the feedback layer;
		
		if (mode == RemoteDrawingSurface.MODE_NORMAL) {
			
			updateUndoRedoHistory();
		}
	}

	public function updateUndoRedoHistory(): Void {
		undoRedoManager.update(bmdCache);
	}

	public function clear() : Void {
		Facade.doLog('clear method call from me', this);
		doRefresh(sizeInfo, true);
	}

	// IVisualElement implementation
	public function refresh(r:Rectangle): Void {
		doRefresh(r);
	}
	
	private function doRefresh(r:Rectangle, ?bIgnoreSizeInfo:Bool = false): Void {
		if (lastSize != null && ! bIgnoreSizeInfo) {
			Facade.doLog('lastSize is not null and we are not ignoring the size info', this);
			if (lastSize.width == r.width && lastSize.height == r.height) {
				Facade.doLog('the size has not change so we leave the room...', this);
				return; // ignore the refresh event...
			}
		}
		lastSize = r.clone();

		if (bmCache != null) {
			removeChild(bmCache);
		}

		if (backGround != null && this.contains(backGround)) {
			removeChild(backGround);
		}

		undoRedoManager.initialize();
		Facade.doLog('the undo redo manager has been initialized', this);

		x = r.x;
		y = r.y;
		
		sizeInfo = r;

		graphics.clear();
		graphics.beginFill(0xffffff, 1);
		graphics.drawRect(1, 1, r.width - 2, r.height - 2);
		graphics.endFill();

		createBmdCache(); 
		
		bmCache = new Bitmap(bmdCache, PixelSnapping.AUTO);
		bmCache.name = "bmpContent";

		undoRedoManager.update(bmdCache);

		if (backGround != null) {
			backGround.addEventListener(Event.ADDED_TO_STAGE, onBackgroundAddedToStage);
			addChild(backGround);
		} else {
			Facade.doLog('no background has been defined', this);
		}

		addChild(bmCache);
		Facade.doLog('End of method doRefresh', this);
	}

	private function onBackgroundAddedToStage(e:Event): Void {
		backGround.removeEventListener(Event.ADDED_TO_STAGE, onBackgroundAddedToStage);
		backGround.draw(sizeInfo);
	}

	private function createBmdCache(): Void {
		if (bmdCache != null) { bmdCache.dispose(); }
		
		bmdCache = new BitmapData(
			Std.int(this.width), 
			Std.int(this.height), 
			true, 
			0xffffff
		);
	}

	public function getDrawingSurface():Graphics{
		return this.graphics;
	}
	public function getInitialSize():Rectangle {
		return new Rectangle(this.x, this.y,  this.width, this.height);
	}
	public function getId():String {
		return name;
	}

	public function setVisible(value:Bool): Void {
		this.visible = value;
	}
}