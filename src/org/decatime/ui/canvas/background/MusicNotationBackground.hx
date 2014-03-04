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

import flash.geom.Rectangle;

class MusicNotationBackground extends BaseBackGround {

	public function new() {
		super(0, 0);
		doSave = true; // we want the background to be saved with the picture
	}

	public override function draw(r:Rectangle): Void {
		// draw horizontal lines...
		var g:Graphics = this.graphics;
		
		var ypos:Float = 48;
		var xpos:Float = 10;
		var i:Int = 0;

		g.clear();
		g.lineStyle( 1 , 0x000000 , 1.0);
		
		while (ypos + 80 < r.height) {
			for (i in 0...5) {
				g.moveTo(10, ypos);
				g.lineTo(r.width - 10, ypos);
				ypos += 16;
			}
			ypos += 48;
		}
	}
}