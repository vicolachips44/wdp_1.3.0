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


class Snapping {
	private var sizeX:Float;
	private var sizeY:Float;
	private var canvas:DrawingSurface;

	public function new(sizeX:Float, sizeY:Float, surface:DrawingSurface) {
		this.sizeX = sizeX;
		this.sizeY = sizeY;
		canvas = surface; // we don't need it but the snapping object is only for DrawingSurface
	}

	public function getSnapPointX(originX:Float): Float {
		var currPos:Float = 0;
		while (currPos < originX) {
			currPos += sizeX;
		}
		if (originX + (sizeX / 2) < currPos) {
			return currPos - sizeX;
		}
		return currPos;
	}

	public function getSnapePointY(originY:Float): Float {
		var currPos:Float = 0;
		while (currPos < originY) {
			currPos += sizeY;
		}
		if (originY + (sizeY / 2) < currPos) {
			return currPos - sizeY;
		}
		return currPos;
	}
}