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
import flash.geom.Rectangle;

import org.decatime.layouts.Layout;
import org.decatime.ui.IVisualElement;

class LayoutContent  implements IVisualElement {
	private var parent:Layout;
	private var size:Float;
	private var item:IVisualElement;
	private var items:Array<IVisualElement>;
	private var innerLayout:Layout;
	public var drawBorder:Bool;
	public var borderSize:Float;
	public var borderColor:Int;
	public var drawFill:Bool;
	public var fillColor:Int;
	public var rowNumber:Int;
	private var initialSize:Rectangle;
	
	public function new(p:Layout, ?s:Float, ?rowNumber:Int) {
		parent = p;
		size = s;
		drawBorder = true;
		borderSize = 1;
		borderColor = 1;
		drawFill = false;
		fillColor = 0x0;
		this.rowNumber = rowNumber;
		this.items = new Array<IVisualElement>();
	}

	public function getParent() {
		return parent;
	}

	public function setInnerLayout(l:Layout) {
		innerLayout = l;
	}

	public function getInnerLayout(): Layout {
		return innerLayout;
	}

	public function getSize(): Float {
		return size;
	}

	public function setSize(value:Float): Void {
		size = value;
	}

	public function addItem(itm:IVisualElement) {
		items.push(itm);
	}

	public function setItem(itm:IVisualElement) {
		item = itm;
	}

	public function getItem(?index:Null<Int>):IVisualElement {
		if (index == null) {
			return item;	
		} else {
			return items[index];
		}
	}

	// IVisualElement implementation
	public function refresh(r:Rectangle): Void {
		initialSize = r;
		if (innerLayout != null) { 
			innerLayout.refresh(r);
		} else if (item != null) {
			item.refresh(r);
		} else {
			var litem:IVisualElement = null;
			for (litem in items) {
				if (litem == null) {
					trace ("WARNING item in items collection is null");
					continue;
				}
				litem.refresh(r);
			}
		}
	}

	public function getId():String {
		if (innerLayout != null) {
			return innerLayout.getId();
		} else if (item != null) {
			return item.getId();
		} else {
			trace ("WARNING : this layout content has more than one item");
			return "";
		}
	}

	public function setVisible(value:Bool): Void {
		if (innerLayout != null) { 
			innerLayout.setVisible(value);
		} else if (item != null) {
			item.setVisible(value);
		} else {
			var litem:IVisualElement = null;
			for (litem in items) {
				litem.setVisible(value);	
			}
		}
	}

	public function getDrawingSurface(): Graphics {
		if (item == null) {
			return parent.getDrawingSurface();
		}
		if (item != null) {
			return item.getDrawingSurface();
		}
		throw "the layout has no item or on than one item";
	}

	public function getInitialSize(): Rectangle {
		if (item != null) {
			return item.getInitialSize();
		} else if (items.length > 0) {
			return items[0].getInitialSize();
		}
		return initialSize;
	}

	public function setInitialSize(size:Rectangle) {
		initialSize = size;
	}
}