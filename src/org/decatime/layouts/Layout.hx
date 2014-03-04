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

import org.decatime.ui.IVisualElement;
import org.decatime.layouts.LayoutContent;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.events.EventManager;

class Layout extends EventManager implements IVisualElement implements IObservable {
	public var hgap:Float;
	public var vgap:Float;
	public var layoutContents:haxe.ds.IntMap<LayoutContent>;
	public var initialSize:Rectangle;
	
	private var element:IVisualElement;
	private var elGraphics:Graphics;
	private var name:String;

	public function new(e:IVisualElement, name:String) {
		super(this);
		element = e;
		this.name = name;
		// if the visual element is a layout then we set the inner parent
		if (Std.is(element, LayoutContent)) {
			cast(element, LayoutContent).setInnerLayout(this);
		}
		// default spacing from the border
		this.hgap = 4;
		this.vgap = 4;
		
		layoutContents = new haxe.ds.IntMap<LayoutContent>();
	}

	public function addLayoutContent(?size:Float, ?rowNum:Int): Int {
		var lcontent:LayoutContent = new LayoutContent(this, size, rowNum);
		lcontent.drawBorder = true;
		var nkey:Int = Lambda.count(layoutContents) + 1;
		layoutContents.set(nkey, lcontent);
		return nkey;
	}

	// IVisualElement implementation
	public function refresh(r:Rectangle): Void {
		throw "you must override this method";
	}

	public function getDrawingSurface(): Graphics {
		return element.getDrawingSurface();
	}

	public function getInitialSize(): Rectangle {
		return this.initialSize;
	}

	public function getId(): String {
		return name;
	}

	public function setVisible(value:Bool): Void {
		for (layout in layoutContents) {
			layout.setVisible(value);
		}
	}

	private function refreshContent(content:LayoutContent, r:Rectangle) {
		content.setInitialSize(r);

		if (elGraphics == null) {
			elGraphics = element.getDrawingSurface();
			if (elGraphics == null) {
				throw ("GRAPHIC ELEMENT IS NULL CAN'T DRAW");	
			}
		}

		if (content.drawBorder) {
			elGraphics.lineStyle(content.borderSize, content.borderColor);
			elGraphics.drawRect(r.x, r.y, r.width, r.height);
		}
		
		content.refresh(r);
	}
}