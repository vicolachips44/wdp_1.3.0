package org.decatime.ui.canvas.effects;

import flash.filters.DropShadowFilter;

import org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import org.decatime.ui.canvas.remote.CmdParser;

class ShadowEffect extends GlowEffect {

	private var distance:Float;
	private var angle:Float;
	private var hideObject:Bool;

	public function new() {
		super();
		
		angle = 45;
		distance = 4;
		hideObject = false;
	}

	public override function getEffect(): flash.filters.BitmapFilter {
		return new DropShadowFilter(
			distance, 
			angle, 
			color, 
			alpha, 
			blurX, 
			blurY, 
			strength, 
			quality, 
			inner, 
			knockout, 
			hideObject);
	}

	public override function getRemoteStruct(): String {
		var strB:StringBuf = new StringBuf();
		
		strB.add(super.getRemoteStruct());
		
		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.EF_ANGLE);
		strB.add(CmdParser.PROP_EQ);
		strB.add(angle);

		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.EF_DISTANCE);
		strB.add(CmdParser.PROP_EQ);
		strB.add(distance);

		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.EF_HIDEOBJ);
		strB.add(CmdParser.PROP_EQ);
		strB.add(hideObject);

		return strB.toString();
	}

	private override function getEffectType(): String {
		return CmdParser.EF_DSHAD;
	}

	public function setAngle(value:Float): Void {
		angle = value;
	}

	public function setDistance(value:Float): Void {
		distance = value;
	}

	public function setHideObject(value:Bool): Void {
		hideObject = value;
	}

}