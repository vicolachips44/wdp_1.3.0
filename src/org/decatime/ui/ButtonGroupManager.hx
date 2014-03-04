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

import flash.events.MouseEvent;
import flash.events.TouchEvent;

import org.decatime.events.IObserver;
import org.decatime.events.IObservable;
import org.decatime.events.EventManager;

class  ButtonGroupManager implements IObservable {
	public static var EVT_SEL_CHANGE:String = "org.decatime.display.ui.ButtonGroupManager.EVT_SEL_CHANGE";

	private var ayOfButtons:Array<PngButton>;
	private var evManager:EventManager;

	public function new() {
		ayOfButtons = new Array<PngButton>();
		evManager = new EventManager(this);
	}

	public function add(instance:PngButton, selected:Bool): Void {
		ayOfButtons.push(instance);
		instance.setGroupManager(this);

		instance.getBtnCold().visible = selected ? false : true;
		instance.getBtnHot().visible = selected;
		if (! selected) {
			#if android
			instance.addEventListener(TouchEvent.TOUCH_END, onBtnTouchEnd);
			#else
			instance.addEventListener(MouseEvent.CLICK, onColdBtnClick);
			#end
		}
	}

	public function select(name:String): PngButton {
		var btn:PngButton = null;
		for (btn in ayOfButtons) {
			if (btn.getId() == name) {
				HandleTogle(btn);
				return btn;
			}
		}
		//trace ("WARNING: select method of object ButtonGroupManager is returning NULL. there is no button with id " + name);
		return null;
	}

	private function onBtnTouchEnd(e:TouchEvent): Void {
		var btn:PngButton = cast(e.currentTarget, PngButton);
		HandleTogle(btn);
	}

	private function onColdBtnClick(e:MouseEvent): Void {
		var btn:PngButton = cast(e.currentTarget, PngButton);
		HandleTogle(btn);
	}

	private function HandleTogle(btn:PngButton, ?bRaiseEvent:Bool = true): Void {
		for (button in ayOfButtons) {
			#if android
			button.removeEventListener(TouchEvent.TOUCH_END, onBtnTouchEnd);
			#else
			button.removeEventListener(MouseEvent.CLICK, onColdBtnClick);
			#end
			if (button.name == btn.name) {
				button.getBtnCold().visible = false;
				button.getBtnHot().visible = true;
				evManager.notify(EVT_SEL_CHANGE, button.name);
			} else {
				button.getBtnCold().visible = true;
				button.getBtnHot().visible = false;
				#if android
				button.addEventListener(TouchEvent.TOUCH_END, onBtnTouchEnd);
				#else
				button.addEventListener(MouseEvent.CLICK, onColdBtnClick);
				#end
			}
		}
	}

	
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