package org.decatime.ui.canvas.effects;

import flash.filters.BlurFilter;

import org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import org.decatime.ui.canvas.remote.CmdParser;

class BlurEffect extends Effect {

	private var blurX:Float;
	private var blurY:Float;
	private var quality:Int;

	public function new() {
		super();
		blurX = 2;
		blurY = 2;
		quality = 1;
	}

	public override function getEffect(): flash.filters.BitmapFilter {
		return new BlurFilter(blurX, blurY, quality);
	}

	private function getEffectType(): String {
		return CmdParser.EF_BLUR;
	}

	public override function getRemoteStruct(): String {
		var strB:StringBuf = new StringBuf();
		strB.add(CmdParser.CMD_TYPE);
		strB.add(CmdParser.PROP_EQ);
		strB.add(getEffectType());
		strB.add(CmdParser.STY_SEP);
		
		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.BLUR_X);
		strB.add(CmdParser.PROP_EQ);
		strB.add(blurX);
		
		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.BLUR_Y);
		strB.add(CmdParser.PROP_EQ);
		strB.add(blurY);
		
		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.QUALITY);
		strB.add(CmdParser.PROP_EQ);
		strB.add(quality);

		return strB.toString();
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