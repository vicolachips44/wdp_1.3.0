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
 
package org.decatime.ui.canvas;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.errors.Error;

import org.decatime.Facade;

class UndoRedoManager {
	private var data:BitmapData;
	private var undoLevel:Int;
	private var undoPosition:Int;
	private var slicePos:Int;

	private var bmdCacheHistory:haxe.ds.IntMap<BitmapData>;

	public function new(data:BitmapData) {
		this.data = data;
		undoPosition = 1;
		slicePos = 1;
		Facade.doLog('the UndoRedoManager instance has been created...', this);
	}

	public function initialize(): Void {
		if (data != null) { 
			data.dispose();
			Facade.doLog('data was not null and has been disposed', this); 
		}
		
		if (bmdCacheHistory != null) {
			Facade.doLog('removing the cache from history', this);
			var nbEl:Int = Lambda.count(bmdCacheHistory);
			for (i in nbEl...1) {
				if (bmdCacheHistory.get(i) != null) {
					bmdCacheHistory.get(i).dispose();
					bmdCacheHistory.remove(i);
				}
			}
			Facade.doLog('the cache is now empty', this);
		}
		
		bmdCacheHistory = new haxe.ds.IntMap<BitmapData>();
		undoPosition = 1;
		Facade.doLog('undo position is now 1', this);
	}

	public function setUndoLevel(value:Int): Void {
		undoLevel = value;
		Facade.doLog('undo level has been setted to ' + value, this);
	}

	public function canUndo(): Bool {
		var tpos:Int = undoPosition - 2;
		var bMove:Bool = bmdCacheHistory.exists(tpos);
		return bMove;
	}

	public function undo(): Void {
		var newPos:Int = undoPosition - 2;

		if (canUndo()) {
			Facade.doLog('doing an undo and moving to position : ' + newPos, this);
			updateDataValue(newPos);
			undoPosition = undoPosition - 1;
		}
	}

	private function updateDataValue(newPos:Int): Void {
		Facade.doLog('updating the cache history from position ' + newPos, this);
		var bmCache:BitmapData = bmdCacheHistory.get(newPos);
		data.copyPixels(
			bmCache, 
			bmCache.rect, 
			new Point(0, 0)
		);
	}

	
	public function canRedo(): Bool {
		var tpos:Int = undoPosition;
		return bmdCacheHistory.exists(tpos);
	}

	public function redo(): Void {
		var newPos:Int = undoPosition;
		if (canRedo()) {
			Facade.doLog('doing a redo and moving to position ' + newPos, this);
			updateDataValue(newPos);
			undoPosition++;
		}
	}

	public function update(dataImg:BitmapData): Void {
		if (undoPosition > undoLevel) {
			Facade.doLog('slicing cache history to next position', this);
			//slice needed
			var toRemove:Int = undoPosition - undoLevel - 1;
			var bmd:BitmapData = bmdCacheHistory.get(toRemove);
			if (bmd != null) { bmd.dispose(); }
			bmdCacheHistory.remove(toRemove);
		}

		data = dataImg;
		initUndoCache(undoPosition);

		var cacheHisto:BitmapData = bmdCacheHistory.get(undoPosition);
		
		cacheHisto.copyPixels(
			dataImg, 
			new Rectangle(0, 0, data.width, data.height), 
			new Point(0,0)
		);
		
		undoPosition++;
	}

	private function initUndoCache(pos:Int): Void {
		//trace ("initializing undo cache...");
		bmdCacheHistory.set(
			pos, 
			new BitmapData(
				data.width, 
				data.height, 
				true, 
				0x000000
			)
		);
		Facade.doLog('initUndoCache method has been called at position ' + pos, this);
	}
}