package org.decatime.wonderpad;

import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.IVisualElement;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.ui.Label;

import flash.geom.Point;

class PanelDocumentProperty extends BoxLayout implements IObserver {
	private var parent:App;
	private var lblPos:Label;

	public function new(parent:App, e:IVisualElement) {
		super(e, DirectionType.HORIZONTAL, 'PanelDocProperty');
		this.parent = parent;

		initialize();
		parent.canvas.addListener(this);
	}

	private function initProVersion(): Void {
		
	}

	private function initialize(): Void {
		lblPos = new Label('lblPos', 'Decatime 2013');
		var idx:Int = this.addLayoutContent(1.0);
		this.layoutContents.get(idx).setItem(lblPos);
		parent.addChild(lblPos);
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic) {
		switch (name) {
			case DrawingSurface.EVT_CURSOR_POS_CHANGED:
				#if !proversion
				var pt:Point = cast(data, Point);
				lblPos.setLabel(pt.x + "," + pt.y);
				#end
		}
	}

	public function getEventCollection(): Array<String> {
		return [
			DrawingSurface.EVT_CURSOR_POS_CHANGED
		];
	}
}