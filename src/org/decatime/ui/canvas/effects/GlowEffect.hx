package org.decatime.ui.canvas.effects;

import flash.filters.GlowFilter;

import org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import org.decatime.ui.canvas.remote.CmdParser;

class GlowEffect extends BlurEffect {

	private var color:UInt;
	private var alpha:Float;
	private var strength:Float;
	private var inner:Bool;
	private var knockout:Bool;

	public function new() {
		super();
		alpha = 1;
		color = 0x000000;
		inner = false;
		knockout = false;
		strength = 2;
	}

	private override function getEffectType(): String {
		return CmdParser.EF_GLOW;
	}

	public function setAlpha(value:Float): Void {
		alpha = value;
	}

	public function setColor(value:Int): Void {
		color = value;
	}

	public function setInner(value:Bool): Void {
		inner = value;
	}

	public function setKnockOut(value:Bool): Void {
		knockout = value;
	}

	public function setStrength(value:Int): Void {
		strength = value;
	}

	public override function getEffect(): flash.filters.BitmapFilter {
		return new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
	}

	public override function getRemoteStruct(): String {
		var strB:StringBuf = new StringBuf();
		
		strB.add(super.getRemoteStruct());

		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.EF_ALPHA);
		strB.add(CmdParser.PROP_EQ);
		strB.add(alpha);

		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.EF_COLOR);
		strB.add(CmdParser.PROP_EQ);
		strB.add(color);

		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.EF_INNER);
		strB.add(CmdParser.PROP_EQ);
		strB.add(inner);

		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.EF_KOUT);
		strB.add(CmdParser.PROP_EQ);
		strB.add(knockout);

		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.EF_STRENGTH);
		strB.add(CmdParser.PROP_EQ);
		strB.add(strength);

		return strB.toString();
	}
}