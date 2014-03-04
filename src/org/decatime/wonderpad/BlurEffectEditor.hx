package org.decatime.wonderpad;

import flash.display.DisplayObject;

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
import org.decatime.ui.canvas.effects.BlurEffect;
import org.decatime.ui.canvas.effects.EffectManager;

class BlurEffectEditor extends BoxLayout implements IObserver {
	private var parent:PopupEffectSel;
	private var hsBlurX:WpHSlider;
	private var hsBlurY:WpHSlider;
	private var hsBlurQuality:WpHSlider;
	private var app:App;
	private var canvas:DrawingSurface;
	private var isActive:Bool;
	private var effManager:EffectManager;
	private var blurEff:BlurEffect;

	public function new(e:IVisualElement, parent:PopupEffectSel) {
		super(e, DirectionType.VERTICAL, 'PanelFreeHandVBox');
		this.parent = parent;
		app = cast (Facade.getInstance().getRoot(), App);
		canvas = app.canvas;
		effManager = Facade.getInstance().getEffectManager();
		blurEff = effManager.getBlurEffect();
		initialize();
	}

	private function initialize(): Void {
		this.vgap = 14;
		layoutContents.set(1, new LayoutContent(this, 40));
		layoutContents.set(2, new LayoutContent(this, 40));
		layoutContents.set(3, new LayoutContent(this, 40));
		layoutContents.set(4, new LayoutContent(this, 1.0));

		hsBlurX = new WpHSlider('hsBlurX', layoutContents.get(1) , this.parent);
		hsBlurX.setMinValue(2);
		hsBlurX.setMaxValue(20);
		hsBlurX.setLabel('Blur X:');
		hsBlurX.setValue(2);
		hsBlurX.pack();
		hsBlurX.addListener(this);

		hsBlurY = new WpHSlider('hsBlurY', layoutContents.get(2) , this.parent);
		hsBlurY.setMinValue(2);
		hsBlurY.setMaxValue(20);
		hsBlurY.setNbDecimal(1);
		hsBlurY.setLabel('Blur Y:');
		hsBlurY.setValue(2);
		hsBlurY.pack();
		hsBlurY.addListener(this);

		hsBlurQuality = new WpHSlider('hsBlurQuality', layoutContents.get(3) , this.parent);
		hsBlurQuality.setMinValue(1);
		hsBlurQuality.setMaxValue(9);
		hsBlurQuality.setLabel('Quality:');
		hsBlurQuality.setValue(2);
		hsBlurQuality.pack();
		hsBlurQuality.addListener(this);

		createChk(layoutContents.get(4), 'chkActive', 'Active', false);
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic) {
		if (name == CheckBox.EVT_CHK_CLICK) {
			Facade.doLog('the active checkbox state has changed', this);
			updateEffectState(data);
		}
		if(name == BaseSlider.EVT_VALUE_CHANGED) {
			Facade.doLog('one of the slider of blur filter has changed', this);
			var ve:WpHSlider = cast(sender, WpHSlider);
			// canvas.removeFilter(blur);
			if (ve.getName() == 'hsBlurX') {
				blurEff.setBlurX(data);
			// 	blur = new BlurFilter(data, hsBlurY.getValue(), Std.int(hsBlurQuality.getValue()));
			} else if (ve.getName() == 'hsBlurY') {
				blurEff.setBlurY(data);
			// 	blur = new BlurFilter(hsBlurX.getValue(), data, Std.int(hsBlurQuality.getValue()));
			} else if (ve.getName() == 'hsBlurQuality') {
				blurEff.setQuality(data);
			// 	blur = new BlurFilter(hsBlurX.getValue(), hsBlurY.getValue(), Std.int(data));
			}
			if (isActive) {
				blurEff.setIsActive(true);
				//canvas.addFilter(blur);
			} else {
				blurEff.setIsActive(false);
			}
			effManager.update();
		}
	}

	public function getEventCollection(): Array<String> {
		return [CheckBox.EVT_CHK_CLICK, BaseSlider.EVT_VALUE_CHANGED];
	}

	private function updateEffectState(bActive:Bool): Void {
		blurEff.setIsActive(bActive);
		isActive = bActive;
		effManager.update();
	}


	private function createChk(
		lcontent:LayoutContent, 
		name:String, 
		label:String, 
		selected:Bool
	) {
		var chk:CheckBox = new CheckBox(name, label);
		parent.addChild(chk);
		lcontent.setItem(chk);
		chk.setSelected(selected);
		chk.addListener(this);
	}
}