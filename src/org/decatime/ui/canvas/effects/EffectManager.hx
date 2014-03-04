package org.decatime.ui.canvas.effects;

import org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import org.decatime.Facade;
import org.decatime.ui.canvas.remote.CmdParser;

class EffectManager {
	var surface:RemoteDrawingSurface;
	var blurEffect:BlurEffect;
	var glowEffect:GlowEffect;
	var shadowEffect:ShadowEffect;

	public function new(dobj:RemoteDrawingSurface) {
		surface = dobj;
		blurEffect = new BlurEffect();
		glowEffect = new GlowEffect();
		shadowEffect = new ShadowEffect();
	}

	public function update(): Void {
		Facade.doLog('entering update method.', this);
		surface.initFilterAy();
		
		var broadCastEff:String = CmdParser.CMD_EFF + CmdParser.CMD_SUFFIX;

		Facade.doLog('surface filters has been initialized', this);

		if (blurEffect.getIsActive()) {
			surface.addFilter(blurEffect.getEffect());
			broadCastEff += blurEffect.getRemoteStruct() + CmdParser.STY_SEP;
			
		}
		
		if (glowEffect.getIsActive()) {
			surface.addFilter(glowEffect.getEffect());
			broadCastEff += glowEffect.getRemoteStruct() + CmdParser.STY_SEP;
		}
		
		if (shadowEffect.getIsActive()) {
			surface.addFilter(shadowEffect.getEffect());
			broadCastEff += shadowEffect.getRemoteStruct() + CmdParser.STY_SEP;
		}

		if (surface.getMode() == RemoteDrawingSurface.MODE_NORMAL) {
			Facade.getInstance().doBroadCast(broadCastEff);
		}
	}

	public function getBlurEffect(): BlurEffect {
		return blurEffect;
	}

	public function getGlowEffect(): GlowEffect {
		return glowEffect;
	}

	public function getShadowEffect(): ShadowEffect {
		return shadowEffect;
	}
}