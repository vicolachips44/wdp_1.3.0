package org.decatime.ui;

import flash.display.SimpleButton;
import flash.geom.Rectangle;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;

import org.decatime.ui.ShapeButton;

class ButtonFactory {

	private function new() { }

	public static function getButton(label:String): SimpleButton {
		var btnSize:Rectangle = new Rectangle(0, 0, 150, 44);
		
		var btn:SimpleButton = new SimpleButton(
		 	new ShapeButton('btnUpState', label, 0xffffff, 0x616161, 0xa1a1a1, btnSize).bitmap,    //upState
		 	new ShapeButton('btnOverState', label, 0x0000fa, 0xa1a1a1, 0xf1f1f1, btnSize).bitmap,  //overState
		 	new ShapeButton('btnDownState', label, 0xffffff, 0x616161, 0xa1a1a1, btnSize).bitmap,  //downState
		 	new ShapeButton('btnHitState', label, 0xffffff, 0x616161, 0xa1a1a1, btnSize).bitmap   //hitTestState
		);

		return btn;
	}
}