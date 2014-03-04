package org.decatime.wonderpad;

import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.IVisualElement;
import org.decatime.ui.canvas.effects.GlowEffect;
import org.decatime.ui.canvas.effects.EffectManager;

class GlowEffectEditor extends ShadowEditor {
	private var glowEff:GlowEffect;

	public function new(e:IVisualElement, parent:PopupEffectSel) {
		super(e, parent);
		glowEff = effManager.getGlowEffect();
	}

	private override function createHsDistance(): Void {
		// no property for this effect
	}

	private override function createHsAngle(): Void {
		// no property for this effect
	}

	private override function createLayouts(): Void {
		super.createLayouts();
		layoutContents.get(3).setSize(1.2);
		layoutContents.get(4).setSize(1.2);
	}

	private override function createChkInnerAndKnockOut(): Void {
		var bVertOptions:BoxLayout = new BoxLayout(this.layoutContents.get(9), DirectionType.HORIZONTAL, 'bVertOptions');
		bVertOptions.hgap = 4;
		bVertOptions.vgap = 1;

		bVertOptions.layoutContents.set(1, new LayoutContent(bVertOptions, 70));
		bVertOptions.layoutContents.set(2, new LayoutContent(bVertOptions, 108));

		createChk(bVertOptions.layoutContents.get(1), 'chkBoxInner', 'Inner', false);
		createChk(bVertOptions.layoutContents.get(2), 'chkBoxKnockOut', 'Knock Out', false);
	}

	private override function rebuildFilter(): Void {
		glowEff.setIsActive(isActive);
		glowEff.setBlurX(hsBlurX.getValue());
		glowEff.setBlurY(hsBlurY.getValue());
		glowEff.setQuality(Std.int(hsBlurQuality.getValue()));
		glowEff.setAlpha(colorAlpha);
		glowEff.setColor(filterColor);
		glowEff.setInner(isInner);
		glowEff.setKnockOut(isKnockOut);
		glowEff.setStrength(Std.int(hsStrength.getValue()));

		effManager.update();
	}

}