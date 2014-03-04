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

package org.decatime.layouts;

import flash.display.Graphics;
import flash.geom.Matrix;
import flash.display.Sprite;
import flash.display.Shape;
import flash.filters.BlurFilter;
import flash.filters.BitmapFilter;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.events.Event;
import flash.geom.Rectangle;

import org.decatime.ui.IVisualElement;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.DirectionType;

class BoxLayout extends Layout {
	private static var NAMESPACE:String = "org.decatime.display.layout.BoxLayout: ";
	public static var EVT_REFRESH_DONE:String = NAMESPACE + "EVT_REFRESH_DONE";

	private var directionType:DirectionType;
	private var nbLayoutContent:Int;
	private var backgroundSprite:Sprite;
	private var bgroundShape:Shape;
	private var bgroundColorStart:Int;
	private var bgroundColorEnd:Int;

	public function new(e:IVisualElement, dt:DirectionType, name:String) {
		super(e, name);
		directionType = dt;
	}

	public function setBackgroundSprite(sprite:Sprite, colorStart:Int, colorEnd:Int) {
		backgroundSprite = sprite;
		bgroundColorStart = colorStart;
		bgroundColorEnd = colorEnd;
	}

	public override function refresh(r:Rectangle): Void {
		this.initialSize = r;
		if (backgroundSprite != null) {
			if (bgroundShape != null) {
				backgroundSprite.removeChild(bgroundShape);	
			}
			
			createBackgroundShape(r);
			
			backgroundSprite.addChild(bgroundShape);

			backgroundSprite.x = r.x - hgap;
			backgroundSprite.y = r.y - vgap;
			
		}

		nbLayoutContent = Lambda.count(this.layoutContents);
		//trace ("the number of layouts in this BoxLayout is " + nbLayoutContent);
		if (this.directionType == DirectionType.HORIZONTAL) {
			horizontalArrange(r);
		} else {
			verticalArrange(r);
		}
		notify(EVT_REFRESH_DONE, r);
	}

	private function createBackgroundShape(r:Rectangle) {
		var box:Matrix = new Matrix();
	    bgroundShape = new Shape();
	    bgroundShape.name = "Asset0." + bgroundShape.name;
	    bgroundShape.graphics.lineStyle(0);
	    box.createGradientBox(r.width, r.height);
	    bgroundShape.graphics.beginGradientFill(GradientType.LINEAR, [bgroundColorStart, bgroundColorEnd], [1, 1], [1, 255], box, SpreadMethod.REFLECT);
	    bgroundShape.graphics.drawRoundRect(0 + hgap, 0 + vgap, r.width, r.height, 8, 8);
	    bgroundShape.graphics.endFill();
	    var asset0Filters:Array<BitmapFilter> = new Array<BitmapFilter>();
	    var blurFilter:BlurFilter = new BlurFilter();
	    asset0Filters.push(blurFilter);
	    bgroundShape.filters = asset0Filters;
	}

	private function verticalArrange(r:Rectangle) {
		var content:LayoutContent = null;
		
		// initialize rectangles
		var rectangles:Array<Rectangle> = new Array<Rectangle>();
		for (i in 0...nbLayoutContent) { rectangles.push(new Rectangle()); }

		var totalWidth:Float = r.width - (hgap * 2);
		var totalHeight:Float = calcWidthAndHeight(r, rectangles);
		var remainingHeight:Float = totalHeight - vgap * nbLayoutContent - vgap;
		calcOrigine(rectangles, remainingHeight, r);
	}

	private function horizontalArrange(r:Rectangle) {
		var content:LayoutContent = null;

		// initialize rectangles
		var rectangles:Array<Rectangle> = new Array<Rectangle>();
		for (i in 0...nbLayoutContent) { rectangles.push(new Rectangle()); }

		var totalWidth:Float = calcWidthAndHeight(r, rectangles);
		var totalHeight:Float = r.height  - (vgap * 2);
		var remainingWidth:Float = totalWidth - hgap * nbLayoutContent - hgap;
		calcOrigine(rectangles, remainingWidth, r);
	}

	private function calcOrigine(r:Array<Rectangle>, rSize:Float, oRect:Rectangle): Void {
		var x:Float = oRect.x + hgap;
		var y:Float = oRect.y + vgap;
		var content:LayoutContent = null;
		for ( i in 1...nbLayoutContent + 1) {
			content = this.layoutContents.get(i);
			var size:Float = content.getSize();
			if (size < 1.1) {
				if (directionType == DirectionType.HORIZONTAL) {
					r[i-1].width = rSize * size;
				} else {
					r[i-1].height = rSize * size;
				}
			}
			r[i-1].x = x;
			r[i-1].y = y;
			if (directionType == DirectionType.HORIZONTAL) {
				// next x position
				x += r[i-1].width + vgap;
			} else {
				// next y position
				y += r[i-1].height + vgap;
			}
			
			refreshContent(content, r[i-1]);
		}
	}

	private function calcWidthAndHeight(oRect:Rectangle, r:Array<Rectangle>): Float {
		var totalSize:Float = directionType == DirectionType.VERTICAL ? oRect.height : oRect.width;
		var content:LayoutContent = null;
		for ( i in 1...nbLayoutContent + 1) {
			content = this.layoutContents.get(i);
			var size:Float = content.getSize();
			if (directionType == DirectionType.VERTICAL) {
				r[i-1].width = oRect.width - (hgap * 2);
			} else {
				r[i-1].height = oRect.height - (vgap * 2);
			}
			if (size < 1.1) { continue; }

			// Absolute size specified
			totalSize -= size;
			if (directionType == DirectionType.VERTICAL) {
				r[i-1].height = size; 
			} else {
				r[i-1].width = size; 
			}
		}
		return totalSize;
	}
}