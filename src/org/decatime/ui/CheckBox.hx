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
import flash.events.MouseEvent;
import flash.display.Bitmap;
import flash.geom.Point;

import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.ui.BaseVisualElement;
import org.decatime.events.EventManager;
import org.decatime.ui.BitmapText;

class CheckBox extends BaseVisualElement implements IObservable {
	public static var EVT_CHK_CLICK: String = "org.decatime.ui.CheckBox.EVT_CHK_CLICK";

	private var idx:Int;
	private var selected :Bool;
	private var label:String;
	private var bmText: Bitmap;
	private var evManager:EventManager;
	
	public function new(n:String, label:String) {
		super(n);
		this.label = label;
		initEventManager();
	}

	private function initEventManager(): Void {
		evManager = new EventManager(this);
		this.addEventListener(MouseEvent.CLICK, onChkClick);
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
		g.drawRect( sizeInfo.x , sizeInfo.y ,  16 , 16 );
		
		if (selected) {
			g.moveTo(sizeInfo.x, sizeInfo.y);
			g.lineTo(sizeInfo.x +  16, sizeInfo.y + 16);
			g.moveTo(sizeInfo.x, sizeInfo.y + 16 );
			g.lineTo(sizeInfo.x +  16, sizeInfo.y );
		}
		if (bmText == null) {
			bmText = BitmapText.getNew(sizeInfo, new Point(24, 0), label);
			addChild(bmText);
		}
	}
	
	public override function refresh(r:Rectangle): Void {
		super.refresh(r);
		paint(selected);
	}

	public override function getInitialSize():Rectangle {
		return new Rectangle(this.x, this.y,  this.width, this.height);
	}

	private function onChkClick(e:MouseEvent): Void {
		setSelected(! selected);
		evManager.notify(EVT_CHK_CLICK, selected);
	}

	// IObservable implementation
	public function addListener(observer:IObserver): Void {
		evManager.addListener(observer);
	}
	public function removeListener(observer:IObserver): Void {
		evManager.removeListener(observer);
	}

	public function notify(name:String, data:Dynamic): Void {
		evManager.notify(name, data);
	}
	// IObservable implementation END
}