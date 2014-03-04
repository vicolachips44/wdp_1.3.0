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

import flash.display.Graphics;
import flash.display.DisplayObject;

import org.decatime.Facade;
import  org.decatime.ui.canvas.remote.CmdParser;
import  org.decatime.ui.canvas.remote.RemoteDrawingSurface;

class FreeHand extends Style {
	public static var BRUSH_LINE:String = "brushLine";
	public static var BRUSH_ROUND:String = "brushRound";
	public static var BRUSH_SQUARE:String = "brushSquare";

	private var brushType:String;
	private var switchTo:Bool;
	private var lastXpos: Float;
	private var lastYPos:Float;
	private var currPacket:StringBuf;
	private var usePacket:Bool;

	public function new(dobj:RemoteDrawingSurface, ?brushType:String, ?stroke:Stroke) {
		super(dobj, stroke);
		usePacket = true;

		if (brushType != null) {
			this.brushType = brushType;
		} else {
			this.brushType = BRUSH_LINE;
		}
	}

	public function setBrushType(brushType:String): Void {
		this.brushType = brushType;
		Facade.getInstance().doBroadCast(this.getRemoteStruct());
	}

	public function getBrushType(): String {
		return brushType;
	}

	public override function prepare(g:Graphics, xpos:Float, ypos:Float): Void {
		super.prepare( g, xpos , ypos );

		g.lineStyle( 
			strokeProperty.getSize() , 
			strokeProperty.getColor() , 
			strokeProperty.getTransparency()
		);
		if (brushType == BRUSH_LINE) {
			switchTo = true;
		}
		if (brushType == BRUSH_ROUND || brushType == BRUSH_SQUARE) {
			g.beginFill(strokeProperty.getColor(), strokeProperty.getTransparency());
		}
		if (surface.getMode() == RemoteDrawingSurface.MODE_NORMAL) {
			var coordToken:String = xpos + CmdParser.COORD_SEP + ypos;
			currPacket = new StringBuf();

			if (usePacket) {
				currPacket.add(CmdParser.XY_PACKET_START);
				currPacket.add(coordToken);
				currPacket.add(CmdParser.PROP_SEP);	
			} else {
				currPacket.add(CmdParser.CMD_START + CmdParser.CMD_SUFFIX);
				currPacket.add(coordToken);
				Facade.getInstance().doBroadCast(currPacket.toString());
			}
		}
	}

	public override function draw(g:Graphics, xpos:Float, ypos: Float): Void {
		// if we are trying to draw the same point...leave
		if (lastXpos == xpos && lastYPos == ypos) { return; }
		var brushSize:Int = strokeProperty.getSize();

		if (brushType == BRUSH_LINE) {
			if (switchTo) {
				g.moveTo(xpos, ypos);
				switchTo = false;
			} else {
				g.lineTo( xpos, ypos);
			}
		}

		if (brushType == BRUSH_ROUND) {
			g.drawCircle(xpos , ypos, brushSize);
		}

		if (brushType == BRUSH_SQUARE) {
			g.drawRect(
				xpos - (brushSize / 2), 
				ypos - (brushSize / 2), 
				brushSize , 
				brushSize 
			);
		}
		if(surface.getMode() == RemoteDrawingSurface.MODE_NORMAL) {
			var coordToken:String = (xpos + CmdParser.COORD_SEP + ypos);
			if (usePacket) {
				currPacket.add(coordToken);
				currPacket.add(CmdParser.PROP_SEP);
			} else {
				currPacket = new StringBuf();
				currPacket.add(CmdParser.CMD_COORD + CmdParser.CMD_SUFFIX);
				currPacket.add(coordToken);
				Facade.getInstance().doBroadCast(currPacket.toString());
			}
		}
		
		// store position
		lastYPos = ypos;
		lastXpos = xpos;
	}

	public override function finalize(g:Graphics, xpos:Float, ypos: Float): Void {
		super.finalize(g, xpos, ypos);
		if (brushType == BRUSH_ROUND || brushType == BRUSH_SQUARE) {
			g.endFill();
		}

		if (surface.getMode() == RemoteDrawingSurface.MODE_NORMAL) {
			var coordToken:String = xpos + CmdParser.COORD_SEP + ypos;
			if (usePacket) {
				currPacket.add(coordToken);
				currPacket.add(CmdParser.XY_PACKET_END);
				Facade.getInstance().doBroadCast(currPacket.toString());
			} else {
				currPacket = new StringBuf();
				currPacket.add(CmdParser.CMD_END + CmdParser.CMD_SUFFIX);
				currPacket.add(coordToken);
				Facade.getInstance().doBroadCast(currPacket.toString());
			}
		}
	}

	public override function getRemoteStruct(): String {
		if (surface.getMode() == RemoteDrawingSurface.MODE_LOADING) { return ""; }
		var strB:StringBuf = new StringBuf();
		strB.add(CmdParser.CMD_STY);
		strB.add(CmdParser.CMD_SUFFIX);
		strB.add(CmdParser.CMD_TYPE);
		strB.add(CmdParser.PROP_EQ);
		strB.add(CmdParser.FH_TYPE);
		strB.add(CmdParser.STY_SEP);
		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.FH_BTYPE);
		strB.add(CmdParser.PROP_EQ);
		strB.add(brushType);
		return strB.toString() + super.getRemoteStruct();
	}

	public override function getType(): String {
		return Style.TYPE_FREEHAND;
	}
}