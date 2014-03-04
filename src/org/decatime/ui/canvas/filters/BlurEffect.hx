package org.decatime.ui.canvas.effects;

import flash.filters.BlurFilter;

import org.decatime.ui.canvas.remote.RemoteDrawingSurface;

class BlurEffect extends Effect {

	private var blurX:Float;
	private var blurY:Float;
	private var quality:Int;

	public function new(dobj:RemoteDrawingSurface) {
		super(dobj);
		blurX = 2;
		blurY = 2;
		quality = 1;
		eff = new BlurFilter(blurX, blurY, quality);
	}

	public function setBlurX(value:Float): Void {
		blurX = value;
	}

	public function setBlurY(value:Float): Void {
		blurY = value;
	}

	public function setQuality(value:Int): Void {
		quality = value;
	}
}