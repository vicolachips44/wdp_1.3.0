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
 
package org.decatime.ui;

import flash.display.Sprite;
import flash.errors.Error;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.display.Graphics;
import flash.text.TextFormat;
import flash.geom.Rectangle;
import flash.display.Bitmap;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import de.polygonal.core.fmt.NumberFormat;

import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.BaseVisualElement;
import org.decatime.ui.BaseShapeElement;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.events.EventManager;
import org.decatime.Facade;

class HSlider extends BaseSlider {
	private var tfield:TextField;
	private var nbDecimal:Int;
	private var label:String;
	private var labelBmp:BaseBmpElement;

	public function new(
		name:String, 
		layoutContent:LayoutContent, 
		parent:Sprite
	) {
		super(name, layoutContent, parent);
		
		value = 0;
		minValue = 0;
		maxValue = 100;
		thumbWidth = 32;
		step = 1;
		nbDecimal = 0;

		tfield = new TextField();
		tfield.selectable = false;
		tfield.autoSize = TextFieldAutoSize.LEFT;
		tfield.mouseEnabled = false;
		tfield.textColor = 0xffffff;
		tfield.y = 2;
		tfield.x = 8;
		tfield.text = '';
		var format:TextFormat = new TextFormat( 
			Facade.getInstance().getDefaultFont().fontName , 
			12 , 
			0xffffff , 
			true , 
			false
		);
		tfield.defaultTextFormat = format;
		tfield.embedFonts = true;

		sliderBar.addChild(tfield);
	}

	public function setLabel(value:String): Void {
		label = value;
	}

	public function setNbDecimal(value:Int): Void {
		nbDecimal = value;
	}

	public override function paint(): Void {
		var g:Graphics = sliderBar.graphics;
		g.beginFill(0x000000);
		var ypos:Float = (slHeight - slBarHeight)/2;
		g.drawRect(0, ypos, slWidth, slBarHeight);
		g.endFill();
		g.lineStyle(2, 0x444444 );
		g.moveTo(2 , (slHeight / 2) - 1);
		g.lineTo(2 , (slHeight / 2) - 1);
		g.lineTo( slWidth - 2, (slHeight / 2) - 1 );
		
		g.lineStyle(2, 0x000000);
		g.drawRect(0, 0, slWidth, slHeight);
		drawSlider(thumbColdColor);
		createLabel();
	}

	private override function drawSlider(in_color:Int): Void {
		var g:Graphics = sliderThumb.graphics;
		g.beginFill(in_color);
		var ypos:Float = (slHeight - thumbHeight)/2;
		g.drawRoundRect(0, ypos, thumbWidth, thumbHeight, 16, 16);
		g.endFill();
		sliderThumb.x = (slWidth - thumbWidth) * ((value - minValue) / maxValue);
		sliderThumb.y = 0.5;
		updateTxtValue();
	}

	private function createLabel(): Void {
		if (labelBmp != null && this.parent.contains(labelBmp)) {
			this.parent.removeChild(labelBmp);
		}

		labelBmp = cast (BitmapText.getNew(
			new Rectangle(1, 1, 80, slHeight- 2) , 
			new Point(0, 0), 
			label
		), BaseBmpElement);
		
		layout.layoutContents.get(1).setItem(labelBmp);
		this.parent.addChild(labelBmp);
	}

	private override function createLayout(): Void {
		layout = new BoxLayout(layoutParent, DirectionType.HORIZONTAL , name + "_sliderLayout");	
		layout.hgap = 0;
		layout.vgap = 0;
		layout.layoutContents.set(1, new LayoutContent(layout, 82));
		layout.layoutContents.set(2, new LayoutContent(layout, 1.0));

		paintArea = layout.layoutContents.get(2);
	}

	

	#if android
	private override function handleTouchMove(e:TouchEvent): Void {
		handleMove(e.localX);
	}
	#else
	private override function handleSliderMove(e:MouseEvent): Void {
		handleMove(e.localX);
	}
	#end

	private function handleMove(xvalue:Float): Void {
		if (sliderThumb.x >= 0 && sliderThumb.x <= slWidth - thumbWidth) {
			sliderThumb.x =  xvalue - startx;
		} else {
			#if android 
			onSliderTouchEnd(null);
			#else
			onSliderMouseUp(null);
			#end
			if (sliderThumb.x > slWidth - thumbWidth) {
				sliderThumb.x = slWidth - thumbWidth;
			}
			if (sliderThumb.x < 0) {
				sliderThumb.x = 0;
			}
		}
		var pcPixel:Float = sliderThumb.x / (slWidth - thumbWidth);
		value = (maxValue * pcPixel) - (minValue * pcPixel) + minValue;

		updateTxtValue();
	}

	private function updateTxtValue(): Void {
		tfield.x = sliderThumb.x + 6;
		tfield.text = NumberFormat.toFixed(value, nbDecimal);
	}
}