package org.decatime.ui.canvas.remote;

import org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import org.decatime.ui.canvas.style.Style;
import org.decatime.ui.canvas.style.FreeHand;
import org.decatime.ui.canvas.style.ShapeStyle;
import org.decatime.ui.canvas.style.TextStyle;
import org.decatime.ui.canvas.style.Stroke;
import org.decatime.ui.canvas.style.Fill;
import org.decatime.ui.canvas.effects.BlurEffect;
import org.decatime.ui.canvas.effects.GlowEffect;
import org.decatime.ui.canvas.effects.ShadowEffect;

import org.decatime.Facade;

class CmdParser {
	public static var XY_PACKET_START:String = "[";
	public static var XY_PACKET_END:String = "]";
	public static var CMD_SUFFIX:String = "|";
	public static var CMD_START:String = "sta";
	public static var CMD_COORD:String = "coo";
	public static var CMD_END:String = "end";
	public static var CMD_CLEAR:String = "cls";
	public static var CMD_UNDO:String = "und";
	public static var CMD_REDO:String = "red";
	public static var CMD_STY:String = "sty";
	public static var CMD_EFF:String = "eff";
	public static var CMD_TYPE:String = "type";
	public static var CMD_CAR:String = "car";
	public static var FH_TYPE:String = "freeHand";
	public static var FH_BTYPE:String = "brushType";
	public static var SH_TYPE:String = "shape";
	public static var SH_GTYPE:String = "shapeType";
	public static var TX_TYPE:String = "text";
	public static var EF_BLUR:String = "blur";
	public static var BLUR_X:String = "blx";
	public static var BLUR_Y:String = "bly";
	public static var QUALITY:String = "qual";
	public static var EF_GLOW:String = "glow";
	public static var EF_ALPHA:String = "alpha";
	public static var EF_COLOR:String = "color";
	public static var EF_INNER:String = "inner";
	public static var EF_KOUT:String = "kout";
	public static var EF_STRENGTH:String = "strength";
	public static var EF_DSHAD:String = "shad";
	public static var EF_ANGLE:String = "ang";
	public static var EF_DISTANCE:String = "dist";
	public static var EF_HIDEOBJ:String = "hobj";
	public static var FRES:String = "fontRes";
	public static var TX_BOLD:String = "bold";
	public static var COORD_SEP:String = ",";
	public static var STY_SEP:String = ";";
	public static var PROP_SEP:String = "-";
	public static var PROP_EQ:String = "=";

	private var canvas:RemoteDrawingSurface;
	private var txtStyle:TextStyle;
	private var freeHandStyle:FreeHand;
	private var shapeStyle:ShapeStyle;

	public function new(canvas:RemoteDrawingSurface) {
		this.canvas = canvas;
	}

	public function parse(msg:String): Void {
		if (msg.length == 0) { return; } // can be a line break
		
		// we don't broadcast received stuff to prevent infinite network loop
		Facade.broadcastEnable(false); 
		
		if(msg.substr( 3 , 1) == CMD_SUFFIX) {
			parseCommand(msg);
			
		} else if (msg.substr(0, 1) == XY_PACKET_START) {
			var i:Int = 0;
			var stripMsg = msg.substr(1, msg.length - 2);
			var coords:Array<String> = stripMsg.split(PROP_SEP);

			var xpos:Float = 0;
			var ypos:Float = 0;
			var pos:Array<String>;

			for (i in 0...coords.length) {
				pos = coords[i].split(COORD_SEP);
				xpos = Std.parseFloat(pos[0]);
				ypos =  Std.parseFloat(pos[1]);
				if (i == 0) {
					canvas.processDown(xpos + canvas.x, ypos + canvas.y);
				} else if (i == coords.length - 1) {
					canvas.processEnd(xpos + canvas.x, ypos + canvas.y);
				} else {
					canvas.processMove(xpos + canvas.x, ypos + canvas.y);
				}
			}
		}
		else {
			//trace ("WARNING: CmdParser: unrecognized message " + msg);
		}
		// we can now broadcast to peers !
		Facade.broadcastEnable(true);
	}

	private function parseCommand(msg:String): Void {
		var token:Array<String> = msg.split(CMD_SUFFIX);
		var cmd:String = token[0];
		if (cmd == CMD_START || cmd == CMD_END || cmd == CMD_COORD) {
			var coord:Array<String> = token[1].split(COORD_SEP);
			var xpos:Float = Std.parseFloat(coord[0]);
			var ypos:Float = Std.parseFloat(coord[1]);
			if (cmd == CMD_START) {
				canvas.processDown(xpos + canvas.x, ypos + canvas.y);
			} else if (cmd == CMD_END) {
				canvas.processEnd(xpos + canvas.x, ypos + canvas.y);
			} else if (cmd == CMD_COORD) {
				canvas.processMove(xpos + canvas.x, ypos + canvas.y);
			}
		} else if (cmd == CMD_CLEAR) {
			canvas.clear();
		} else if (cmd == CMD_UNDO) {
			canvas.undo();
		} else if (cmd == CMD_REDO) {
			canvas.redo();
		} else if (cmd == CMD_STY) {
			parseStyle(token[1]);
		} else if (cmd == CMD_CAR) {
			parseTxtContent(token[1]);
		} else if (cmd == CMD_EFF) {
			parseEff(token[1]);
		} else  {
			Facade.doLog('WARNING unknown command : ' + cmd, this);
		}
	}

	private function parseEff(effMsg:String): Void {
		var effects:Array<String> = effMsg.split(STY_SEP);
		var effectType:String = "";
		
		var blur:BlurEffect = Facade.getInstance().getEffectManager().getBlurEffect();
		blur.setIsActive(false);

		var glow:GlowEffect = Facade.getInstance().getEffectManager().getGlowEffect();
		glow.setIsActive(false);

		var shad:ShadowEffect = Facade.getInstance().getEffectManager().getShadowEffect();
		shad.setIsActive(false);

		for (i in 0...effects.length) {
			effectType = effects[i];
			if (effectType == CMD_TYPE + PROP_EQ + EF_BLUR) {
				var props:Array<String> = effects[i + 1].split(PROP_SEP);
				buildBlurEffect(blur, props);

			} else if (effectType == CMD_TYPE + PROP_EQ + EF_GLOW) {
				var props:Array<String> = effects[i + 1].split(PROP_SEP);
				buildGlowEffect(glow, props);
			} else if (effectType == CMD_TYPE + PROP_EQ + EF_DSHAD) {
				var props:Array<String> = effects[i + 1].split(PROP_SEP);
				buildShadowEffect(shad, props);
				
			}
		}
		Facade.getInstance().getEffectManager().update();
	}

	private function buildBlurEffect(blur:BlurEffect, props:Array<String>): Void {
		var blurXProp:Array<String> = props[1].split(PROP_EQ);
		var blurX:Float = Std.parseFloat(blurXProp[1]);

		var blurYProp:Array<String> = props[2].split(PROP_EQ);
		var blurY:Float = Std.parseFloat(blurYProp[1]);

		var qualityProp:Array<String> = props[3].split(PROP_EQ);
		var quality:Int = Std.parseInt(qualityProp[1]);

		blur.setBlurX(blurX);
		blur.setBlurY(blurY);
		blur.setQuality(quality);
		blur.setIsActive(true);
	}

	private function buildGlowEffect(glow:GlowEffect, props:Array<String>): Void {
		var blurXProp:Array<String> = props[1].split(PROP_EQ);
		var blurX:Float = Std.parseFloat(blurXProp[1]);

		var blurYProp:Array<String> = props[2].split(PROP_EQ);
		var blurY:Float = Std.parseFloat(blurYProp[1]);

		var qualityProp:Array<String> = props[3].split(PROP_EQ);
		var quality:Int = Std.parseInt(qualityProp[1]);
		//----------------------------------------------------
		var alphaProp:Array<String> = props[4].split(PROP_EQ);
		var alpha:Float = Std.parseFloat(alphaProp[1]);

		var clProp:Array<String> = props[5].split(PROP_EQ);
		var cl:Int = Std.parseInt(clProp[1]);

		var innerProp:Array<String> = props[6].split(PROP_EQ);
		var isInner:Bool = innerProp[1] == 'true' ? true : false;

		var koutProp:Array<String> = props[7].split(PROP_EQ);
		var isKout:Bool = innerProp[1] == 'true' ? true: false;

		var stProp:Array<String> = props[8].split(PROP_EQ);
		var st:Int = Std.parseInt(stProp[1]);
		
		glow.setBlurX(blurX);
		glow.setBlurY(blurY);
		glow.setQuality(quality);
		glow.setAlpha(alpha);
		glow.setColor(cl);
		glow.setInner(isInner);
		glow.setKnockOut(isKout);
		glow.setStrength(st);
		glow.setIsActive(true);
	}

	private function buildShadowEffect(shad:ShadowEffect, props:Array<String>): Void {
		var blurXProp:Array<String> = props[1].split(PROP_EQ);
		var blurX:Float = Std.parseFloat(blurXProp[1]);

		var blurYProp:Array<String> = props[2].split(PROP_EQ);
		var blurY:Float = Std.parseFloat(blurYProp[1]);

		var qualityProp:Array<String> = props[3].split(PROP_EQ);
		var quality:Int = Std.parseInt(qualityProp[1]);
		
		var alphaProp:Array<String> = props[4].split(PROP_EQ);
		var alpha:Float = Std.parseFloat(alphaProp[1]);

		var clProp:Array<String> = props[5].split(PROP_EQ);
		var cl:Int = Std.parseInt(clProp[1]);

		var innerProp:Array<String> = props[6].split(PROP_EQ);
		var isInner:Bool = innerProp[1] == 'true' ? true : false;

		var koutProp:Array<String> = props[7].split(PROP_EQ);
		var isKout:Bool = innerProp[1] == 'true' ? true: false;

		var stProp:Array<String> = props[8].split(PROP_EQ);
		var st:Int = Std.parseInt(stProp[1]);
		//----------------------------------------------------
		var angleProp:Array<String> = props[9].split(PROP_EQ);
		var angle:Float = Std.parseFloat(angleProp[1]);

		var distProp:Array<String> = props[10].split(PROP_EQ);
		var dist:Float = Std.parseFloat(distProp[1]);

		var hideObjProp:Array<String> = props[11].split(PROP_EQ);
		var hideObj:Bool = hideObjProp[1] == 'true' ? true : false;

		shad.setBlurX(blurX);
		shad.setBlurY(blurY);
		shad.setQuality(quality);
		shad.setAlpha(alpha);
		shad.setColor(cl);
		shad.setInner(isInner);
		shad.setKnockOut(isKout);
		shad.setStrength(st);
		shad.setAngle(angle);
		shad.setDistance(dist);
		shad.setHideObject(hideObj);
		shad.setIsActive(true);
	}

	private function parseTxtContent(text:String): Void {
		var ts:TextStyle = cast(canvas.getActiveStyle(), TextStyle);
		ts.setText(text);
	}

	private function parseStyle(styMsg:String): Void {
		var tokens:Array<String> = styMsg.split(STY_SEP);
		var typeOfStyle:Array<String> = tokens[0].split(PROP_EQ);
		if (typeOfStyle[1] == FH_TYPE) {
			canvas.setActiveStyle(getBrushStyle(tokens[1]));
		} else if (typeOfStyle[1] == SH_TYPE) {
			canvas.setActiveStyle(getShapeStyle(tokens[1]));
		} else if (typeOfStyle[1] == TX_TYPE) {
			canvas.setActiveStyle(getTextStyle(tokens[1]));
		} else {
		}
	}

	private function getTextStyle(token:String): TextStyle {
		var tokens:Array<String> = token.split(PROP_SEP);
		var fontRes:Array<String> = tokens[1].split(PROP_EQ);

		if (txtStyle == null) {
			txtStyle = new TextStyle(canvas, fontRes[1]);
		}
		txtStyle.setFontRes(fontRes[1]);
		var stroke:Stroke = getStrokeTextFromProp(txtStyle, tokens);
		txtStyle.setStrokeProperty(stroke);
		return txtStyle;
	}

	private function getShapeStyle(token:String): ShapeStyle {
		var tokens:Array<String> = token.split(PROP_SEP);
		var shapeType:Array<String> = tokens[1].split(PROP_EQ);

		if(shapeStyle == null) {
			shapeStyle = new ShapeStyle(canvas);
		}

		shapeStyle.setShapeType(shapeType[1]);
		var stroke:Stroke = getStrokeFromProp(shapeStyle, tokens);
		var fill:Fill = getFillFromProp(shapeStyle, tokens);
		shapeStyle.setStrokeProperty(stroke);
		shapeStyle.setFillProperty(fill);

		return shapeStyle;
	}

	private function getBrushStyle(token:String): FreeHand {
		var tokens:Array<String> = token.split(PROP_SEP);
		
		var brushType:Array<String> = tokens[1].split(PROP_EQ);

		if (freeHandStyle == null) {
			freeHandStyle = new FreeHand(canvas, brushType[1]);
		}

		freeHandStyle.setBrushType(brushType[1]);
		var stroke:Stroke = getStrokeFromProp(freeHandStyle, tokens);
		freeHandStyle.setStrokeProperty(stroke);

		return freeHandStyle;
	}

	private function getFillFromProp(parent:Style, props:Array<String>): Fill {
		var clValue:Array<String> = props[5].split(PROP_EQ);
		var trans:Array<String> = props[6].split(PROP_EQ);
		var newTrans:Float = Std.parseFloat(StringTools.replace(trans[1], ",", "."));

		return new Fill(
			parent,
			Std.parseInt(clValue[1]), 
		 	newTrans
		 );
	}

	private function getStrokeTextFromProp(parent:Style, props:Array<String>): Stroke  {
		var clValue:Array<String> = props[3].split(PROP_EQ);
		var trans:Array<String> = props[4].split(PROP_EQ);
		var newTrans:Float = Std.parseFloat(StringTools.replace(trans[1], ",", "."));
		var sz:Array<String> = props[5].split(PROP_EQ);

		return new Stroke(
			parent,
		 	Std.parseInt(clValue[1]) , 
		 	newTrans , 
		 	Std.parseInt(sz[1])
		 );
	}

	private function getStrokeFromProp(parent:Style, props:Array<String>): Stroke  {
		var clValue:Array<String> = props[2].split(PROP_EQ);
		var trans:Array<String> = props[3].split(PROP_EQ);
		var newTrans:Float = Std.parseFloat(StringTools.replace(trans[1], ",", "."));
		var sz:Array<String> = props[4].split(PROP_EQ);

		return new Stroke(
			parent,
		 	Std.parseInt(clValue[1]) , 
		 	newTrans , 
		 	Std.parseInt(sz[1])
		 );
	}
}