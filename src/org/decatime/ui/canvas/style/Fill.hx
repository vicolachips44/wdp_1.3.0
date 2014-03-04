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

import de.polygonal.core.fmt.NumberFormat;

import  org.decatime.ui.canvas.remote.CmdParser;

class Fill {
	private var color:Int;
	private var transparency:Float;
	private var parent:Style;

	public function new(parent:Style, ?cl:Int, ?trans:Float) {
		this.parent = parent;
		if (cl != null) { 
			color = cl; 
		} else {
			color = 0x000000;
		}
		if (trans != null) {
			transparency = trans;
		} else {
			transparency = 1.0;
		}
	}

	public function getColor(): Int {
		return color;
	}
	public function setColor(value:Int): Void {
		if( color == value) { return; }
		color = value;
		Facade.doBroadCast(parent.getRemoteStruct());
	}

	public function getTransparency(): Float {
		return transparency;
	}
	public function setTransparency(value:Float): Void {
		if (transparency == value) { return; }
		transparency = value;
		Facade.doBroadCast(parent.getRemoteStruct());
	}

	public function toString(): String {
		var strValueOfTrans:String = StringTools.replace( NumberFormat.toFixed(transparency, 2), ".", ",");
		var bld:StringBuf = new StringBuf();
		bld.add(CmdParser.PROP_SEP);
		bld.add("color");
		bld.add(CmdParser.PROP_EQ);
		bld.add(color);
		bld.add(CmdParser.PROP_SEP);
		bld.add("trans");
		bld.add(CmdParser.PROP_EQ);
		bld.add(strValueOfTrans);
		
		return bld.toString(); //"-color=" + color + "-trans=" + strValueOfTrans;
	}
}