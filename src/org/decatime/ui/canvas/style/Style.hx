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
 
package  org.decatime.ui.canvas.style;

import flash.display.DisplayObject;
import flash.display.Graphics;
import  org.decatime.ui.canvas.remote.RemoteDrawingSurface;

class Style implements IDrawable {
	public static var TYPE_FREEHAND:String = "freeHand";
	public static var TYPE_SHAPE:String = "shape";
	public static var TYPE_TEXT:String = "text";
	private var strokeProperty: Stroke;
	private var fillProperty:Fill;
	private var drawStarted:Bool;
	private var surface:RemoteDrawingSurface;
	private var startX:Float;
	private var startY:Float;
	private var endX:Float;
	private var endY:Float;
	private var blnNeedFeedBack:Bool;
	private var blnNeedsXY:Bool;

	public function new(dobj:RemoteDrawingSurface, ?stroke:Stroke) {
		strokeProperty = stroke;
		if (strokeProperty == null) {
			strokeProperty = new Stroke(this);
		}
		surface = dobj;
		blnNeedFeedBack = true;
		blnNeedsXY = false;
		drawStarted = false;
		startX = 0;
		startY = 0;
		endX = 0;
		endY = 0;
		fillProperty = new Fill(this, 0x000000, 1.0);
	}

	public function cleanUp(): Void {
		// override this to do some cleanUp...
	}

	public function needsFeedBack(): Bool {
		return blnNeedFeedBack;
	}

	public function needsXY(): Bool {
		return blnNeedsXY;
	}

	public function getStrokeProperty(): Stroke {
		return strokeProperty;
	}

	public function setStrokeProperty(value:Stroke): Void {
		strokeProperty = value;
	}

	public function getFillProperty(): Fill {
		return fillProperty;
	}

	public function setFillProperty(value:Fill): Void {
		if (value == null) {
			//trace("WARNING: setting value to null is not allowed");
		}
		fillProperty = value;
		Facade.getInstance().doBroadCast(this.getRemoteStruct());
	}

	// IDrawable implementation
	public function prepare(g:Graphics, xpos:Float, ypos: Float): Void {
		startX = xpos;
		startY = ypos;
		drawStarted = true;
	}

	public function draw(g:Graphics, xpos:Float, ypos: Float): Void {
		throw "override method";
	}

	public function finalize(g:Graphics, xpos:Float, ypos: Float): Void {
		endX = xpos;
		endY = ypos;
		drawStarted = false;
	}
	// IDrawable implementation - END

	public function getRemoteStruct(): String {
		if (surface.getMode() == RemoteDrawingSurface.MODE_LOADING) { return ""; }
		var strB:StringBuf = new StringBuf();
		if (this.strokeProperty != null) {
			strB.add(this.strokeProperty.toString());
		}
		if (this.fillProperty != null) {
			strB.add(this.fillProperty.toString());
		}
		return strB.toString();
	}

	public function getType(): String {
		throw "override this method";
		return "";
	}
	
}