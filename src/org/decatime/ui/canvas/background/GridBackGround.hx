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
import de.polygonal.core.math.Mathematics;

class GridBackGround extends BaseBackGround {

	private var gridColor:Int;
	private var gridOpacity:Float;

	public function new(sizeX:Float, sizeY:Float) {
		super(sizeX, sizeY);
		gridColor = 0xd6d6d6;
		gridOpacity = 1.0;
		hasCustCoordinate = true;
	}

	public override function translateCoordinate(originX:Float, originY:Float): Point {
		var t:Int = M.exp(10, 0);
		return new Point(
			(Std.int((originX/sizeX) * t) / t) + 1,
			(Std.int((originY/sizeY) * t) / t) + 1
		);
	}

	public override function draw(r:Rectangle): Void {
		//trace ("grid is drawing with this size info: " + r.height);
		// draw horizontal lines...
		var g:Graphics = this.graphics;
		
		var ypos:Float = sizeY;
		var xpos:Float = sizeX;

		g.clear();
		g.lineStyle( 1 , gridColor , gridOpacity);
		
		if (ypos > -1) {
			while (ypos < r.height) {
				g.moveTo( 0, ypos );
				g.lineTo( r.width , ypos );
				ypos+= sizeY;
			}
		}

		if (xpos > -1) {
			while (xpos < r.width) {
				g.moveTo( xpos, 0 );
				g.lineTo( xpos , r.height );
				xpos+= sizeX;
			}
		}
	}
}