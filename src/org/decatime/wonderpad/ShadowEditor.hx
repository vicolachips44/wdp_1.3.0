package org.decatime.wonderpad;

import flash.display.DisplayObject;
import flash.display.Sprite;

import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.ui.CheckBox;
import org.decatime.ui.IVisualElement;
import org.decatime.ui.BaseSlider;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.DirectionType;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.Facade;
import org.decatime.ui.canvas.effects.ShadowEffect;
import org.decatime.ui.canvas.effects.EffectManager;

class ShadowEditor extends BoxLayout implements IObserver implements IColorPropertyHolder {
	private static var THUMB_HEIGHT:Int = 18;
	private static var HS_HEIGHT:Int = 20;

	private var parent:PopupEffectSel;
	private var app:App;
	private var canvas:DrawingSurface;
	private var distance:Float;
	private var angle:Float;
	private var isHideObject:Bool;
	private var hsDistance:WpHSlider;
	private var hsAngle:WpHSlider;
	private var hsBlurX:WpHSlider;
	private var hsBlurY:WpHSlider;
	private var hsBlurQuality:WpHSlider;
	private var hsStrength:WpHSlider;
	private var filterColor:Int;
	private var colorAlpha:Float;
	private var isInner:Bool;
	private var isKnockOut:Bool;
	private var isActive:Bool;
	private var chkActive:CheckBox;
	private var effManager:EffectManager;
	private var shadowEff:ShadowEffect;

	public function new(e:IVisualElement, parent:PopupEffectSel) {
		super(e, DirectionType.VERTICAL, 'PanelFreeHandVBox');
		this.parent = parent;
		app = cast (Facade.getInstance().getRoot(), App);
		canvas = app.canvas;
		effManager = Facade.getInstance().getEffectManager();
		shadowEff = effManager.getShadowEffect();
		isInner = false;
		isKnockOut = false;
		isActive = false;
		filterColor = 0x000000;
		colorAlpha = 1.0;
		distance = 45;
		angle = 45;
		isHideObject = false;
		initialize();
	}

	public function getContainer(): Sprite {
		return cast (this.parent, Sprite);
	}

	public function updateForeColor(value:Int): Void {
		
	}

	public function updateBackColor(value:Int): Void {
		//trace ("new back color detected");
		filterColor = value;
		rebuildFilter();
	}

	public function updateForeColorAlpha(value:Float): Void {
		
	}

	public function updateBackColorAlpha(value: Float): Void {
		colorAlpha = value;
		rebuildFilter();
	}

	private function initialize(): Void {
		this.vgap = 0;
		createLayouts();
		
		var pnColor:PanelColorProperty = new PanelColorProperty( 
			layoutContents.get(1), 
			this 
		);
		chkActive = createChk(layoutContents.get(2), 'chkActive', 'Active', false);
		
		createHsDistance();
		createHsAngle();
		createHsBlurX();
		createHsBlurY();
		createHsBlurQuality();
		createHsStrength();
		createChkInnerAndKnockOut();
	}

	private function createHsDistance(): Void {
		hsDistance = new WpHSlider('hsDistance', layoutContents.get(3) , this.parent);
		hsDistance.setMinValue(1);
		hsDistance.setMaxValue(20);
		hsDistance.setHeight(HS_HEIGHT);
		hsDistance.setThumbHeight(THUMB_HEIGHT);
		hsDistance.setLabel('Distance: ');
		hsDistance.setValue(6);
		hsDistance.pack();
		hsDistance.addListener(this);
	}

	private function createHsAngle(): Void {
		hsAngle = new WpHSlider('hsAngle', layoutContents.get(4) , this.parent);
		hsAngle.setMinValue(1);
		hsAngle.setMaxValue(20);
		hsAngle.setHeight(HS_HEIGHT);
		hsAngle.setThumbHeight(THUMB_HEIGHT);
		hsAngle.setLabel('Angle: ');
		hsAngle.setValue(6);
		hsAngle.pack();
		hsAngle.addListener(this);
	}

	private function createHsBlurX(): Void {
		hsBlurX = new WpHSlider('hsBlurX', layoutContents.get(5) , this.parent);
		hsBlurX.setMinValue(1);
		hsBlurX.setMaxValue(20);
		hsBlurX.setHeight(HS_HEIGHT);
		hsBlurX.setThumbHeight(THUMB_HEIGHT);
		hsBlurX.setLabel('Blur X:');
		hsBlurX.setValue(6);
		hsBlurX.pack();
		hsBlurX.addListener(this);
	}

	private function createHsBlurY(): Void {
		hsBlurY = new WpHSlider('hsBlurY', layoutContents.get(6) , this.parent);
		hsBlurY.setMinValue(1);
		hsBlurY.setMaxValue(20);
		hsBlurY.setHeight(HS_HEIGHT);
		hsBlurY.setThumbHeight(THUMB_HEIGHT);
		hsBlurY.setLabel('Blur Y:');
		hsBlurY.setValue(6);
		hsBlurY.pack();
		hsBlurY.addListener(this);
	}

	private function createHsBlurQuality(): Void {
		hsBlurQuality = new WpHSlider('hsBlurQuality', layoutContents.get(7) , this.parent);
		hsBlurQuality.setMinValue(1);
		hsBlurQuality.setMaxValue(9);
		hsBlurQuality.setHeight(HS_HEIGHT);
		hsBlurQuality.setThumbHeight(THUMB_HEIGHT);
		hsBlurQuality.setLabel('Quality:');
		hsBlurQuality.setValue(1);
		hsBlurQuality.pack();
		hsBlurQuality.addListener(this);
	}

	private function createHsStrength(): Void {
		hsStrength = new WpHSlider('hsStrength', layoutContents.get(8) , this.parent);
		hsStrength.setMinValue(1);
		hsStrength.setMaxValue(96);
		hsStrength.setHeight(HS_HEIGHT);
		hsStrength.setThumbHeight(THUMB_HEIGHT);
		hsStrength.setLabel('Strength:');
		hsStrength.setValue(2);
		hsStrength.pack();
		hsStrength.addListener(this);
	}

	private function createChkInnerAndKnockOut(): Void {
		var bVertOptions:BoxLayout = new BoxLayout(this.layoutContents.get(9), DirectionType.HORIZONTAL, 'bVertOptions');
		bVertOptions.hgap = 4;
		bVertOptions.vgap = 1;

		bVertOptions.layoutContents.set(1, new LayoutContent(bVertOptions, 70));
		bVertOptions.layoutContents.set(2, new LayoutContent(bVertOptions, 108));
		bVertOptions.layoutContents.set(3, new LayoutContent(bVertOptions, 100));

		createChk(bVertOptions.layoutContents.get(1), 'chkBoxInner', 'Inner', false);
		createChk(bVertOptions.layoutContents.get(2), 'chkBoxKnockOut', 'Knock Out', false);
		createChk(bVertOptions.layoutContents.get(3), 'chkHideObject', 'Hide object', false);
	}

	private function createLayouts(): Void {
		layoutContents.set(1, new LayoutContent(this, 120)); // color and alpha
		layoutContents.set(2, new LayoutContent(this, 26));  // Active chk
		layoutContents.set(3, new LayoutContent(this, 26));  // distance
		layoutContents.set(4, new LayoutContent(this, 26));  // angle
		layoutContents.set(5, new LayoutContent(this, 26));  // blur X
		layoutContents.set(6, new LayoutContent(this, 26));  // blur Y
		layoutContents.set(7, new LayoutContent(this, 26));  // blur quality
		layoutContents.set(8, new LayoutContent(this, 26));  // strength
		layoutContents.set(9, new LayoutContent(this, 26));  // inner & KnockOut & hideObject
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic) {
		if (name == CheckBox.EVT_CHK_CLICK) {
			var chk:CheckBox = cast(sender, CheckBox);
			if (chk.getId() == 'chkActive') {
				isActive = data;
			}
			if (chk.getId() == 'chkBoxInner') {
				isInner = data;
			}
			if (chk.getId() == 'chkBoxKnockOut') {
				isKnockOut = data;
			}
			if (chk.getId() == 'chkHideObject') {
				isHideObject = data;
			}
			rebuildFilter();
		}
		if (name == BaseSlider.EVT_VALUE_CHANGED) {
			rebuildFilter();
		}
	}

	public function getEventCollection(): Array<String> {
		return [CheckBox.EVT_CHK_CLICK];
	}

	private function rebuildFilter(): Void {
		shadowEff.setIsActive(isActive);
		shadowEff.setBlurX(hsBlurX.getValue());
		shadowEff.setBlurY(hsBlurY.getValue());
		shadowEff.setQuality(Std.int(hsBlurQuality.getValue()));
		shadowEff.setAlpha(colorAlpha);
		shadowEff.setColor(filterColor);
		shadowEff.setInner(isInner);
		shadowEff.setKnockOut(isKnockOut);
		shadowEff.setStrength(Std.int(hsStrength.getValue()));
		shadowEff.setAngle(hsAngle.getValue());
		shadowEff.setDistance(hsDistance.getValue());
		shadowEff.setHideObject(isHideObject);

		effManager.update();
	}

	private function updateEffectState(bActive:Bool): Void {
		isActive = bActive;
		rebuildFilter();
	}


	private function createChk(
		lcontent:LayoutContent, 
		name:String, 
		label:String, 
		selected:Bool
	): CheckBox {
		var chk:CheckBox = new CheckBox(name, label);
		parent.addChild(chk);
		lcontent.setItem(chk);
		chk.setSelected(selected);
		chk.addListener(this);
		return chk;
	}
}