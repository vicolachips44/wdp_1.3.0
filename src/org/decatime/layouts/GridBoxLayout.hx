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

package org.decatime.layouts;

import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;
import flash.errors.Error;
import flash.geom.Rectangle;

import org.decatime.layouts.Layout;
import org.decatime.layouts.LayoutContent;
import org.decatime.ui.IVisualElement;
import org.decatime.ui.BaseVisualElement;
import org.decatime.Facade;

class GridBoxLayout extends Layout {
	public static var CELL_CLICK_EVT:String = "org.decatime.display.ui.GridBoxLayout.GRIDBOX_CELL_CLICK_EVT";

	private var columnsCount:Int;
	private var rowsCount:Int;
	private var drawFill:Bool;
	private var raiseClickOnCell:Bool;
	private var selectedElement:IVisualElement;
	private var layoutContentCount:Int;
	
	public function new(e:IVisualElement, name:String, c:Int, r:Int) {
		super(e, name);
		columnsCount = c;
		rowsCount = r;
		drawFill = false;
		raiseClickOnCell = false;
		layoutContentCount = 0;
		initLayoutContent();
	}

	public function setDrawFill(value:Bool) {
		drawFill = value;
	}

	public function setRaiseClickOnCell(value:Bool) {
		raiseClickOnCell = value;
	}

	public function setSelected(element:IVisualElement) {
		if (selectedElement != null) {
			removeFocusRectangle();
		}

		drawFocusRectangle(element);
		selectedElement = element;
	}

	public function getSelected(): IVisualElement {
		return selectedElement;
	}

	public function getCellByColor(color:Int): IVisualElement {
		var content:LayoutContent = null;
		if (layoutContentCount == 0) { 
			//trace ("WARNING: layoutContentCount property is empty...");
			return null; 
		}
		
		for (i in 1...layoutContentCount + 1) {
			content = this.layoutContents.get(i);
			if (content.borderColor == color) {
				return content.getItem();
			}
		}
		return null;
	}

	private function initLayoutContent(): Void {
		var l:LayoutContent = null;
		
		var kv:Int = 0;
		var data:String = "";
		for (j in 0...rowsCount) {
			for (i in 0...columnsCount) {
				kv++;
				l = new LayoutContent(this, 0, j + 1);
				this.layoutContents.set(kv, l);
			}
		}
	}

	public override function refresh(r:Rectangle): Void {
		this.initialSize = r;

		var totalWidth:Float = r.width  - (hgap * columnsCount) - hgap;
		var totalHeight:Float = r.height - (vgap * rowsCount) - vgap;

		var lcWidth:Float = totalWidth / columnsCount;
		var lcHeight:Float = totalHeight / rowsCount;

		var content:LayoutContent = null;
		layoutContentCount = Lambda.count(this.layoutContents);
		var i:Int = 0;

		var currX:Float = r.x + hgap;
		var currY:Float = r.y + vgap;

		var curRow:Int = 1;

		for (i in 1...layoutContentCount + 1) {
			content = this.layoutContents.get(i);
			if (curRow <  content.rowNumber)  {
				curRow++;
				currX = r.x + hgap;
				currY += lcHeight + vgap;
			}
			var cRect = new Rectangle(currX,currY,lcWidth,lcHeight);

			this.refreshContent(content, cRect);
			
			if (content.getItem() == null || content.getDrawingSurface() == null) {
				currX += lcWidth + hgap;
				continue;
			}

			if (drawFill) {
				var g:Graphics = content.getDrawingSurface();
				g.beginFill(content.borderColor, 1);
				g.drawRect(currX,currY,lcWidth,lcHeight);
			}

			if (selectedElement != null && selectedElement.getId() == content.getId()) {
				drawFocusRectangle(selectedElement, content);
			}

			if (raiseClickOnCell) {
				if (Std.is(content.getItem(), InteractiveObject)) {
					var d:InteractiveObject = cast (content.getItem(), InteractiveObject);
					d.addEventListener(MouseEvent.CLICK, onCellClick);
				} else {
					throw new Error("raiseClickOnCell is set to true but item content is not an instance of InteractiveObject");
				}
			}

			currX += lcWidth + hgap;
		}
	}

	private function onCellClick(e:MouseEvent) {
		var ve:InteractiveObject = cast (e.currentTarget, InteractiveObject);
		notify(CELL_CLICK_EVT, ve.name);
		setSelected(cast (ve, IVisualElement));
	}

	private function drawFocusRectangle(item:IVisualElement, ?element:LayoutContent) {
		if (element == null) {
			element = getElementById(item.getId());
			if (element == null) {
				throw new Error("Error while trying to get an instance of LayoutContent object");
			}
		}
		
		if (item == null) {
			throw new Error("Item of type IVisualElement is null");
		}

		var g:Graphics = item.getDrawingSurface();
		if (g == null) {
			throw new Error("cannot draw focus rectangle from an item element with no graphics property");
		}

		g.lineStyle( 4 , 0x0 , 1);
		var size:Rectangle = element.getInitialSize();
		if (size == null) {
			throw new Error("cannot draw focus because the initial size is not setted");
		} else {
			g.drawRect(size.x, size.y, size.width, size.height);
			g.beginFill(element.borderColor, 1);
			g.drawRect(size.x, size.y, size.width, size.height);	
			g.endFill();	
		}
	}

	public function getElementById(id:String): LayoutContent {
		var content:LayoutContent = null;
		layoutContentCount = Lambda.count(this.layoutContents); // refreshing the count value
		for (i in 1...layoutContentCount + 1) {
			content = this.layoutContents.get(i);
			if (content.getId() == id) {
				return content;
			}
		}
		return null;
	}

	private function removeFocusRectangle() {
		var element:LayoutContent = getElementById(selectedElement.getId());
		
		var g:Graphics = selectedElement.getDrawingSurface();
		if (g == null) {
			throw new Error("cannot remove focus rectangle from an item element with no graphics property");
		}
		g.clear();
		
		g.beginFill(element.borderColor, 1);
		var size:Rectangle = element.getInitialSize();
		g.drawRect(size.x, size.y, size.width, size.height);	
		g.endFill();
	}
}