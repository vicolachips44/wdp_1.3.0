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
 
package org.decatime.utils;

import org.decatime.utils.HtmlColor;

class ColorPalette {
	private static var instance:ColorPalette;

	private var htmlColors:Array<HtmlColor>;
	private static var nbColors:Int;

	private function new() {
		htmlColors = new Array<HtmlColor>();
		initialize();
		nbColors = Lambda.count(htmlColors);
	}

	public static function getChart():ColorPalette {
		if (instance == null) {
			instance = new ColorPalette();
		}
		return instance;
	}

	public function colors():Array<HtmlColor> {
		return htmlColors;
	} 

	public function byName(name:String): HtmlColor {
		for (i in 0...nbColors) {
			if (htmlColors[i].colorName == name) {
				return htmlColors[i];
			}
		}
		return null;
	}

	private function initialize() {
		htmlColors.push(new HtmlColor("Black",0x000000));
		htmlColors.push(new HtmlColor("Silver",0xC0C0C0));
		htmlColors.push(new HtmlColor("Gray",0x808080));
		htmlColors.push(new HtmlColor("White",0xFFFFFF));
		htmlColors.push(new HtmlColor("Maroon",0x800000));
		htmlColors.push(new HtmlColor("Red",0xFF0000));
		htmlColors.push(new HtmlColor("Purple",0x800080));
		htmlColors.push(new HtmlColor("Fuchsia",0xFF00FF));
		htmlColors.push(new HtmlColor("Green",0x008000));
		htmlColors.push(new HtmlColor("Lime",0x00FF00));
		htmlColors.push(new HtmlColor("Olive",0x808000));
		htmlColors.push(new HtmlColor("Yellow",0xFFFF00));
		htmlColors.push(new HtmlColor("Navy",0x000080));
		htmlColors.push(new HtmlColor("Blue",0x0000FF));
		htmlColors.push(new HtmlColor("Teal",0x008080));
		htmlColors.push(new HtmlColor("Aqua",0x00FFFF));
	}
}