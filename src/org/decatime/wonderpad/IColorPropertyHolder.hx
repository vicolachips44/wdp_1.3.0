package org.decatime.wonderpad;

import flash.display.Sprite;

interface IColorPropertyHolder {
	function getContainer(): Sprite;
	function updateForeColor(value:Int): Void;
	function updateBackColor(value:Int): Void;
	function updateForeColorAlpha(value:Float): Void;
	function updateBackColorAlpha(value:Float): Void;
}