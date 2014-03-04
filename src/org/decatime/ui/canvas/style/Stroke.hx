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

import  org.decatime.ui.canvas.remote.CmdParser;

class Stroke extends Fill {
	public static var DEF_SIZE:Int = 3;

	private var size:Int;

	public function new(parent:Style, ?cl:Int, ?trans:Float, ?sz:Int) {
		super(parent, cl, trans);
		if (sz != null) {
			size = sz;
		} else {
			size = DEF_SIZE;
		}
	}

	public function getSize(): Int {
		return size;
	}
	public function setSize(value:Int): Void {
		if (size == value) { return; }
		size = value;
		Facade.getInstance().doBroadCast(parent.getRemoteStruct());
	}

	public override function toString(): String {
		var val:String = super.toString();
		return val + CmdParser.PROP_SEP + "size" + CmdParser.PROP_EQ + size;
		//return val + "-size=" + size;
	}
}