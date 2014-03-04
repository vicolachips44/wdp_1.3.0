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
 
package org.decatime.ui;

import flash.display.Graphics;
import flash.geom.Rectangle;
import flash.display.Bitmap;
import flash.geom.Point;

import org.decatime.ui.BaseVisualElement;
import org.decatime.Facade;
import org.decatime.ui.RadioButtonGroup;
import org.decatime.ui.BitmapText;

class RadioButton extends BaseVisualElement {
	private var idx:Int;
	private var selected :Bool;
	private var group:RadioButtonGroup;
	private var label:String;
	private var bmText: Bitmap;

	public function new(n:String, group:RadioButtonGroup, label:String) {
		super(n);
		this.group = group;
		group.add(this);
		this.label = label;
	}

	public function isSelected() {
		return selected;
	}

	public function setSelected(blnValue:Bool) {
		selected = blnValue;
		if (sizeInfo == null) { return; }
		paint(selected);
	}

	private function paint(selected:Bool): Void {
		var g:Graphics = this.graphics;
		g.clear();
		g.beginFill(0xffffff, 0.01);
		g.lineStyle( 0 , 0x000000 , 0.0);
		g.drawRect(sizeInfo.x, sizeInfo.y, sizeInfo.width, sizeInfo.height);
		g.endFill();
		g.lineStyle( 1 , 0x000000 , 1.0);
		g.drawCircle(sizeInfo.x + 8, sizeInfo.y + 8, 8 );
		if (selected) {
			g.beginFill(0x000000, 1);
			g.drawCircle(sizeInfo.x + 8, sizeInfo.y + 8, 4 );
			g.endFill();
		}
		if (bmText == null) {
			bmText = BitmapText.getNew(sizeInfo, new Point(24, 0), label);
			addChild(bmText);
		}
	}

	private function createLabel(): Void {
		
	}
	
	public override function refresh(r:Rectangle): Void {
		super.refresh(r);
		paint(selected);
	}

	public override function getInitialSize():Rectangle {
		return new Rectangle(this.x, this.y,  this.width, this.height);
	}
}