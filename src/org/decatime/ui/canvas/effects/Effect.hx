package org.decatime.ui.canvas.effects;

import flash.filters.BitmapFilter;

import org.decatime.ui.canvas.remote.RemoteDrawingSurface;

class Effect {
	public static var TYPE_BLUR:String = "blur";
	public static var TYPE_GLOW:String = "glow";
	public static var TYPE_SHADOW:String = "shad";

	private var eff:BitmapFilter;
	private var active:Bool;
	
	public function new() {
		active = false;	
	}

	public function getEffect(): BitmapFilter {
		throw "should not be call directly";
		return null;
	}

	public function getIsActive(): Bool {
		return active;
	}

	public function setIsActive(value:Bool): Void {
		active = value;
	}

	public function getRemoteStruct(): String {
		throw "must be overrided";
		return "ghost";
	}
}