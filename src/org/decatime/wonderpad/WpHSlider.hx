package org.decatime.wonderpad;

import flash.display.Sprite;

import org.decatime.ui.HSlider;
import org.decatime.layouts.LayoutContent;

class WpHSlider extends HSlider {
	public function new(
		name:String, 
		layoutContent:LayoutContent, 
		parent:Sprite
	) {
		super(name, layoutContent, parent);

		setNbDecimal(0);
		setWidth(200);
		setHeight(40);
		setSliderBarHeight(4);
		setThumbWidth(64);
		setThumbHeight(32);
		setThumbColdColor(0x000000);
		setThumbHotColor(0x333333);
	}
}