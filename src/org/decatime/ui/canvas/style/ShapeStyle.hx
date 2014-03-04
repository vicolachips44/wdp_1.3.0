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

import  org.decatime.ui.canvas.remote.CmdParser;
import  org.decatime.ui.canvas.Snapping;
import  org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import org.decatime.Facade;

class ShapeStyle extends Style {
	public static var SHAPE_LINE:String = "shapeLine";
	public static var SHAPE_SQUARE:String = "shapeSquare";
	public static var SHAPE_CIRCLE:String = "shapeCircle";

	private var lastXpos: Float;
	private var lastYPos:Float;
	private var shapeType:String;
	private var snapper:Snapping;

	public function new(dobj:RemoteDrawingSurface, ?stroke:Stroke, ?fill:Fill, ?shapeType:String) {
		super(dobj, stroke);
		if (shapeType == null) {
			this.shapeType = SHAPE_LINE;
		} else {
			this.shapeType = shapeType;
		}
		blnNeedsXY = true;
	}

	public function snapToGrid(gridX:Float, gridY:Float): Void {
		if (Std.is(surface, DrawingSurface)) {
			//trace ("creating an instance of snapping object");
			snapper = new Snapping(gridX , gridY , cast (surface, DrawingSurface));
		}
	}

	public function disableSnap(): Void {
		snapper = null;
	}

	public function setShapeType(value:String): Void {
		if (shapeType == value) { return; }
		shapeType = value;
		Facade.getInstance().doBroadCast(this.getRemoteStruct());
	}

	public override function prepare(g:Graphics, xpos:Float, ypos:Float): Void {
		if (snapper == null) {
			super.prepare( g, xpos , ypos );
		} else {
			startX = snapper.getSnapPointX(xpos);
			startY = snapper.getSnapePointY(ypos);
			drawStarted = true;
		}

		var msg:String = "" + (startX) + "," + (startY) + "";
		Facade.getInstance().doBroadCast(CmdParser.CMD_START + CmdParser.CMD_SUFFIX + msg);
	}

	public override function draw(g:Graphics, xpos:Float, ypos: Float): Void {
		// if we are trying to draw the same point...leave
		if (lastXpos == xpos && lastYPos == ypos) { return; }
		doDraw(g, xpos, ypos);
	}

	private function doDraw(g:Graphics, xpos:Float, ypos: Float): Void {
		g.clear();

		if (strokeProperty != null) {
			g.lineStyle(
				strokeProperty.getSize(), 
				strokeProperty.getColor(), 
				strokeProperty.getTransparency()
			);
		}

		if (fillProperty != null && shapeType != SHAPE_LINE) {
			g.beginFill(fillProperty.getColor(), fillProperty.getTransparency());
		}	

		if (shapeType == SHAPE_LINE) {
			g.moveTo(startX, startY);
			g.lineTo( xpos, ypos);
		}

		if (shapeType == SHAPE_SQUARE) {
			g.drawRect(startX, startY , xpos - startX , ypos - startY);
		}

		if (shapeType == SHAPE_CIRCLE) {
			g.drawCircle( startX , startY , xpos  - startX );
		}
		
		lastYPos = ypos;
		lastXpos = xpos;
	}

	public override function finalize(g:Graphics, xpos:Float, ypos: Float): Void {
		var msg:String = "" + (xpos) + "," + (ypos) + "";
		if (snapper == null) {
			super.finalize(g, xpos, ypos);
			doDraw(g, xpos, ypos);
		} else {
			endX = snapper.getSnapPointX(xpos);
			endY = snapper.getSnapePointY(ypos);
			doDraw(g, endX, endY);
			msg = "" + (endX) + "," + (endY) + "";
		}
		Facade.getInstance().doBroadCast(CmdParser.CMD_END + CmdParser.CMD_SUFFIX + msg);
		drawStarted = false;
	}

	public override function getRemoteStruct(): String {
		var strB:StringBuf = new StringBuf();
		strB.add(CmdParser.CMD_STY);
		strB.add(CmdParser.CMD_SUFFIX);
		strB.add(CmdParser.CMD_TYPE);
		strB.add(CmdParser.PROP_EQ);
		strB.add(CmdParser.SH_TYPE);
		strB.add(CmdParser.STY_SEP);
		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.SH_GTYPE);
		strB.add(CmdParser.PROP_EQ);
		strB.add(shapeType);
		return strB.toString() + super.getRemoteStruct();
	}

	public override function getType(): String {
		return Style.TYPE_SHAPE;
	}
}