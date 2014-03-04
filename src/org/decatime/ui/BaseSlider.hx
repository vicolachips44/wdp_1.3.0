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
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.display.Graphics;
import flash.geom.Rectangle;

import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.BaseVisualElement;
import org.decatime.ui.BaseShapeElement;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.events.EventManager;

class BaseSlider implements IObservable {
	public static var EVT_VALUE_CHANGING:String = "org.decatime.display.ui.BaseSlider.EVT_VALUE_CHANGING";
	public static var EVT_VALUE_CHANGED:String = "org.decatime.display.ui.BaseSlider.EVT_VALUE_CHANGED";

	private var name:String;
	private var layoutParent:LayoutContent;
	private var parent:Sprite;
	private var layout:BoxLayout;
	private var sliderBar:BaseVisualElement;
	private var sliderThumb:BaseShapeElement;
	private var value:Float;
	private var minValue:Float;
	private var maxValue:Float;
	private var step:Float;
	private var paintArea:LayoutContent;
	private var startx:Float;
	private var starty:Float;
	private var packed:Bool;
	private var evManager:EventManager;
	private var slWidth:Float;
	private var slHeight:Float;
	private var slBarHeight:Float;
	private var thumbWidth:Float;
	private var thumbHeight:Float;
	private var thumbColdColor:Int;
	private var thumbHotColor:Int;

	public function new(
		name:String, 
		layoutContent:LayoutContent, 
		parent:Sprite
	) {
		
		thumbColdColor = 0x0000ca;
		thumbHotColor = 0x0000ff;

		this.name = name;
		this.layoutParent = layoutContent;
		this.parent = parent;
		evManager = new EventManager(this);
		createLayout();
		initializeComponent();
	}

	public function getName(): String {
		return name;
	}

	public function setThumbHotColor(value:Int): Void {
		thumbHotColor = value;
	}

	public function setThumbColdColor(value:Int): Void {
		thumbColdColor = value;
	}

	public function pack(): Void {
		if (packed) { throw "The component pack method has already been called"; }
		sliderBar.addEventListener(Event.ADDED_TO_STAGE, onslBarAddedToStage);
		
		parent.addChild(sliderBar);
	}

	public function setThumbWidth(value:Float): Void {
		thumbWidth = value;
	}

	public function setThumbHeight(value:Float): Void {
		thumbHeight = value;
	}

	public function setWidth(value:Float): Void {
		slWidth = value;
	}

	public function getWidth(): Float {
		return slWidth;
	}

	public function setHeight(value:Float): Void {
		slHeight = value;
	}

	public function setSliderBarHeight(value:Float): Void {
		slBarHeight = value;
	}

	public function getHeight(): Float {
		return slHeight;
	}

	public function setMinValue(value:Float): Void {
		minValue = value;
	}
	public function getMinValue(): Float {
		return minValue;
	}

	public function setMaxValue(value:Float): Void {
		maxValue = value;
	}
	public function getMaxValue(): Float {
		return maxValue;
	}

	public function getValue(): Float {
		return value;
	}

	public function setValue(newValue:Float): Void {
		if (value == newValue) { return; } // nothing has changed...
		value = newValue;
		drawSlider(thumbColdColor);
	}

	public function setStep(value:Float): Void {
		step = value;
	}

	public function getStep(): Float {
		return step;
	}

	public function paint(): Void {
		throw "You must implement this method";
	}

	private function drawSlider(in_color:Int): Void {
		throw "You must implement this method";
	}

	private function onslBarAddedToStage(e:Event): Void {
		sliderBar.removeEventListener(Event.ADDED_TO_STAGE, onslBarAddedToStage);
		packed = true;
		paint();
	}

	private function createLayout(): Void {
		throw "you must implement this method";
	}

	private function initializeComponent(): Void {
		sliderBar = new BaseVisualElement(name + '_sliderBar');
		sliderBar.isContainer = false;

		sliderThumb = new BaseShapeElement(name + '_sliderThumb');
		sliderBar.addChild(sliderThumb);
		paintArea.setItem(sliderBar);
		#if android
		sliderBar.addEventListener(TouchEvent.TOUCH_BEGIN, onSliderTouchBegin);
		#else
		sliderBar.addEventListener(MouseEvent.MOUSE_DOWN, onSliderMouseDown);
		#end
	}

	// Events handlers Section
	#if android
	private function onSliderTouchBegin(e:TouchEvent): Void {
		if (sliderBar.hitTestObject(sliderThumb )) {
			startx = sliderThumb.mouseX;
			starty = sliderThumb.mouseY;
			drawSlider(thumbHotColor);
			sliderBar.addEventListener(TouchEvent.TOUCH_END, onSliderTouchEnd);
			sliderBar.addEventListener(TouchEvent.TOUCH_MOVE, onSliderTouchMove);
		}
	}

	private function onSliderTouchMove(e:TouchEvent): Void {
		handleTouchMove(e);
		evManager.notify(EVT_VALUE_CHANGING, value);
	}

	private function handleTouchMove(e:TouchEvent): Void {
		throw "you must implement this method";
	}

	private function onSliderTouchEnd(e:TouchEvent): Void {
		drawSlider(thumbColdColor);
		evManager.notify(EVT_VALUE_CHANGED, value);
		sliderBar.removeEventListener(TouchEvent.TOUCH_END, onSliderTouchEnd);
		sliderBar.removeEventListener(TouchEvent.TOUCH_MOVE, onSliderTouchMove);
	}

	#else

	private function onSliderMouseDown(e:MouseEvent): Void {
		if (sliderBar.hitTestObject(sliderThumb )) {
			startx = sliderThumb.mouseX;
			starty = sliderThumb.mouseY;
			drawSlider(thumbHotColor);
			sliderBar.addEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp);
			sliderBar.addEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove);
			sliderBar.addEventListener(MouseEvent.MOUSE_OUT, onSliderMouseUp);
		}
	}

	private function onSliderMouseMove(e:MouseEvent): Void {
		handleSliderMove(e);
		evManager.notify(EVT_VALUE_CHANGING, value);
	}

	private function handleSliderMove(e:MouseEvent): Void {
		throw "you must implement this method";
	}

	private function onSliderMouseUp(e:MouseEvent): Void {
		drawSlider(thumbColdColor);
		evManager.notify(EVT_VALUE_CHANGED, value);
		sliderBar.removeEventListener(MouseEvent.MOUSE_MOVE, onSliderMouseMove);
		sliderBar.removeEventListener(MouseEvent.MOUSE_UP, onSliderMouseUp);
		sliderBar.removeEventListener(MouseEvent.MOUSE_OUT, onSliderMouseUp);
	}
	#end
	// Events handlers Section END

	// IObservable implementation
	public function addListener(observer:IObserver): Void {
		evManager.addListener(observer);
	}
	public function removeListener(observer:IObserver): Void {
		evManager.removeListener(observer);
	}

	public function notify(name:String, data:Dynamic): Void {
		evManager.notify(name, data);
	}
	// IObservable implementation END
}