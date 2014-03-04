package org.decatime.ui.canvas;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.geom.Point;

class GuideLayer extends Sprite {
	private var surface:DrawingSurface;

	public function new(ds:DrawingSurface) {
		super();
		surface = ds;
		this.cacheAsBitmap = true;
		this.mouseEnabled = false;
		this.addEventListener(Event.ADDED_TO_STAGE, onLayerAddedToStage);
		ds.addChild(this);
	}

	private function onLayerAddedToStage(e:Event): Void {
		removeEventListener(Event.ADDED_TO_STAGE, onLayerAddedToStage);
	}

	public function clear() {
		graphics.clear();
	}

	public function drawGuide(p:Point): Void {
		graphics.clear();

		if (p.x < 10 || p.y < 10) { return; }
		if (p.x > surface.width - 10) { return; }
		if (p.y > surface.height - 10) { return; }

		graphics.beginFill(0xff0000, 0.5);
		graphics.drawRect(0, p.y , surface.width , 1);
		graphics.drawRect(p.x, 0 , 1 , surface.height);
		graphics.endFill();
	}
}