package org.decatime.ui;

import org.decatime.events.IObserver;
import org.decatime.events.IObservable;
import org.decatime.events.EventManager;

import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;

class BaseScrollBar extends BaseVisualElement implements IObservable {
	private static var NAMESPACE:String = "org.decatime.display.ui.BaseScrollBar :";
	public static var EVT_SCROLL:String = NAMESPACE + "EVT_SCROLL";

	private var evManager:EventManager;
	private var parentLayout:LayoutContent;

	public function new(name:String, parentLayout:LayoutContent) {
		super(name);
		evManager = new EventManager(this);
		this.parentLayout = parentLayout;
		this.parentLayout.setItem(this);
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