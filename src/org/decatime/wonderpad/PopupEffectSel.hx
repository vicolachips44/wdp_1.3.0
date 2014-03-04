package org.decatime.wonderpad;

import flash.display.Sprite;
import flash.geom.Rectangle;

import org.decatime.ui.Window;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.RadioButtonGroup;
import org.decatime.ui.RadioButton;
import org.decatime.ui.PngButton;
import org.decatime.ui.ButtonGroupManager;
import org.decatime.events.IObserver;
import org.decatime.events.IObservable;

class PopupEffectSel extends Window implements IObserver {
	public static var POPUP_NAME:String = 'PopupEffectSel';

	private var canvas:DrawingSurface;
	private var btnGpManager:ButtonGroupManager;
	private var layoutContentForPanel:LayoutContent;
	private var pnBlurEditor:BlurEffectEditor;
	private var pnGlowEditor:GlowEffectEditor;
	private var pnGlowInit:Bool;
	private var pngDShadowEditor:ShadowEditor;
	private var pnDShadowInit:Bool;

	public function new(canvas:DrawingSurface) {
		super(POPUP_NAME, 'Effects', canvas);
		titleFont = "assets/VeraMono.ttf";
		this.canvas = canvas;
		position = new Rectangle(0, 0, 320, 430);
		btnGpManager = new ButtonGroupManager();
		btnGpManager.addListener(this);
		Facade.getInstance().getDocManager().addListener(this);
	}



	private override function createClientArea(clientArea:LayoutContent): Void {
		var boxv1:BoxLayout = new BoxLayout(clientArea, DirectionType.VERTICAL, 'boxv1');
		boxv1.hgap = 4;
		boxv1.vgap = 1;

		var boxv1_l1:LayoutContent = new LayoutContent(boxv1, 60);
		boxv1.layoutContents.set(1, boxv1_l1);
		layoutContentForPanel = new LayoutContent(boxv1, 1.0);
		boxv1.layoutContents.set(2, layoutContentForPanel);

		var boxh_tabs:BoxLayout = new BoxLayout( 
			boxv1_l1, 
			DirectionType.HORIZONTAL, 
			'boxh_tabs' 
		);
		boxh_tabs.hgap = 1;
		boxh_tabs.vgap = 1;

		// a boxlayout object can also have a gradient background
		var spriteBackground:Sprite = new Sprite();
		// we added to this instance of sprite to the app sprite and the layout will do its job.
		addChild(spriteBackground);
		boxh_tabs.setBackgroundSprite(spriteBackground, 0x999999, 0xffffff);

		var boxh_tabs_l1:LayoutContent = new LayoutContent(boxh_tabs, 44);
		boxh_tabs.layoutContents.set(1, boxh_tabs_l1);
		var boxh_tabs_l2:LayoutContent = new LayoutContent(boxh_tabs, 44);
		boxh_tabs.layoutContents.set(2, boxh_tabs_l2);
		var boxh_tabs_l3:LayoutContent = new LayoutContent(boxh_tabs, 44);
		boxh_tabs.layoutContents.set(3, boxh_tabs_l3);

		var btnBlurEffect:PngButton = new PngButton(
			'btnBlurEffect', 
			"assets/btn_blurEffect_cold.png", 
			"assets/btn_blurEffect_hot.png"
		);
		btnGpManager.add(btnBlurEffect, true);
		boxh_tabs_l1.setItem(btnBlurEffect);
		addChild(btnBlurEffect);

		var btnGlowEffect:PngButton = new PngButton(
			'btnGlowEffect', 
			"assets/btn_glowEffect_cold.png", 
			"assets/btn_glowEffect_hot.png"
		);
		btnGpManager.add(btnGlowEffect, false);
		boxh_tabs_l2.setItem(btnGlowEffect);
		addChild(btnGlowEffect);

		var btnDpShdEffect:PngButton = new PngButton(
			'btnDpShdEffect', 
			"assets/btn_dropShadow_cold.png", 
			"assets/btn_dropShadow_hot.png"
		);
		btnGpManager.add(btnDpShdEffect, false);
		boxh_tabs_l3.setItem(btnDpShdEffect);
		addChild(btnDpShdEffect);

		pngDShadowEditor = new ShadowEditor(layoutContentForPanel, this);
		pnGlowEditor = new GlowEffectEditor( layoutContentForPanel, this);
		pnBlurEditor = new BlurEffectEditor(layoutContentForPanel, this);

		pngDShadowEditor.setVisible(false);
		pnGlowEditor.setVisible(false);
	}

	public override function handleEvent(name:String, sender:IObservable, data:Dynamic): Void {
		super.handleEvent(name, sender, data);
		switch (name) {
		case ButtonGroupManager.EVT_SEL_CHANGE:
			//trace ("group management changed..");
			if (data == 'btnBlurEffect') {
				pnBlurEditor.setVisible(true);
				pnGlowEditor.setVisible(false);
				pngDShadowEditor.setVisible(false);
			} 
			if (data == 'btnGlowEffect') {
				if (! pnGlowInit) {
					pnGlowEditor.refresh(layoutContentForPanel.getInitialSize());
					pnGlowInit = true;
				}
				pnGlowEditor.setVisible(true);
				pnBlurEditor.setVisible(false);
				pngDShadowEditor.setVisible(false);
			}
			if (data == 'btnDpShdEffect') {
				if (! pnDShadowInit) {
					pngDShadowEditor.refresh(layoutContentForPanel.getInitialSize());
					pnDShadowInit = true;
				}
				pnGlowEditor.setVisible(false);
				pnBlurEditor.setVisible(false);
				pngDShadowEditor.setVisible(true);
			}
		}
	}
}