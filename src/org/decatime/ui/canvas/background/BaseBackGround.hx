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
 
package  org.decatime.ui.canvas.background;

import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Point;
import flash.geom.Rectangle;

class BaseBackGround extends Shape {

	private var sizeX: Float;
	private var sizeY:Float;
	private var doSave:Bool;
	private var hasCustCoordinate:Bool;

	public function new(sizeX:Float, sizeY:Float) {
		super();
		this.sizeX = sizeX;
		this.sizeY = sizeY;
		doSave = true;
		hasCustCoordinate = false;
	}

	public function getHasCustCoordinate(): Bool {
		return hasCustCoordinate;
	}

	public function translateCoordinate(xpos:Float, ypos:Float): Point {
		if (hasCustCoordinate) {
			throw "override this method";
		}
		return null;
	}

	public function getDoSave(): Bool {
		return doSave;
	}

	public function draw(r:Rectangle): Void {
		//trace ("WARNING: draw call on en empty background !!");
	}
}