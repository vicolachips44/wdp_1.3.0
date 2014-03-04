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

import org.decatime.ui.RadioButton;
import org.decatime.Facade;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.events.EventManager;

class RadioButtonGroup implements IObservable {
	public static var EVT_RDB_CLICK: String = "org.decatime.display.ui.RadioButtonGroup.CLICK_EVENT";

	private var name:String;
	private var radioButtons:Array<RadioButton>;
	private var evManager:EventManager;

	public function new(n:String) {
		name = n;
		radioButtons = new Array<RadioButton>();
		evManager = new EventManager(this);
	}

	public function add(r:RadioButton): Void {
		radioButtons.push(r);
		r.addEventListener(MouseEvent.CLICK, onRdbClick);
	}

	public function get(idx:Int): RadioButton {
		return radioButtons[idx];
	}

	public function select(name:String,  ?bNotify:Bool = false): Void {
		var rdb:RadioButton = null;
		
		for (rdb in radioButtons) {
			if (rdb.name == name) {
				if (rdb.isSelected() == false) {
					rdb.setSelected(true);
					if (bNotify) {
						evManager.notify(EVT_RDB_CLICK, name);	
					}
				}
			} else {
				rdb.setSelected(false);
			}
		}
	}

	private function onRdbClick(e:MouseEvent): Void {
		var sender:RadioButton = cast (e.currentTarget, RadioButton);
		var rdb:RadioButton = null;
		select(sender.name, true);
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