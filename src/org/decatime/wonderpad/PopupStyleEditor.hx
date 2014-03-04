package org.decatime.wonderpad;

import flash.display.Sprite;

import org.decatime.ui.Window;
import org.decatime.events.IObserver;
import org.decatime.events.IObservable;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.Facade;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.PngButton;
import org.decatime.ui.ButtonGroupManager;
import org.decatime.ui.canvas.style.FreeHand;
import org.decatime.ui.canvas.style.ShapeStyle;
import org.decatime.ui.canvas.style.TextStyle;
import org.decatime.ui.canvas.style.Stroke;
import org.decatime.ui.canvas.style.Fill;
import org.decatime.ui.canvas.style.Style;

class PopupStyleEditor extends Window implements IObserver implements IColorPropertyHolder  {
	public static var POPUP_NAME:String = 'PopupStyleEditor';

	private var canvas:DrawingSurface;
	private var app:App;
	private var btnGpManager:ButtonGroupManager;
	private var pnFreeHand:PanelFreeHandEditor;
	private var pnShape:PanelShapeEditor;
	private var pnTextEditor:PanelTextEditor;
	private var pnPalEditor:PanelPaletteEditor;
	private var pnStrokeEditor:PanelStrokeEditor;
	private var layoutContentForPanel:LayoutContent;
	private var styFreeHand:FreeHand;
	private var styShape:ShapeStyle;
	private var styText:TextStyle;
	private var pnShapeInit:Bool;
	private var pnTextInit:Bool;
	private var pnFillInit:Bool;
	private var pnStrokeInit:Bool;

	public function new(canvas:DrawingSurface) {
		super(POPUP_NAME, 'Style Editor', canvas);
		
		this.canvas = canvas;
		canvas.addListener(this);
		titleFont = "assets/VeraMono.ttf";
		initStyles();
		
		app = cast(Facade.getInstance().getRoot(), App);
		btnGpManager = new ButtonGroupManager();
		btnGpManager.addListener(this);
	}

	public function getStyFreeHand(): FreeHand {
		return styFreeHand;
	}

	public function getStyShape(): ShapeStyle {
		return styShape;
	}

	public function getStyText(): TextStyle {
		return styText;
	}

	private function initStyles(): Void {
		styFreeHand = new FreeHand(canvas);
		styFreeHand.setStrokeProperty(new Stroke(styFreeHand, 0x000000 , 1.0 , 3 ));
		

		styShape = new ShapeStyle(canvas);
		styShape.setStrokeProperty(new Stroke(styShape, 0x000000 , 1.0 , 3 ));
		styShape.snapToGrid(18.86, 18.86);
		styText = new TextStyle(canvas, 'assets/lcd.ttf');
		styText.setStrokeProperty(new Stroke(styText, 0x000000 , 1.0 , 20 ));
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
		var boxh_tabs_l4:LayoutContent = new LayoutContent(boxh_tabs, 44);
		boxh_tabs.layoutContents.set(4, boxh_tabs_l4);
		var boxh_tabs_l5:LayoutContent = new LayoutContent(boxh_tabs, 44);
		boxh_tabs.layoutContents.set(5, boxh_tabs_l5);
		var boxh_tabs_l6:LayoutContent = new LayoutContent(boxh_tabs, 1.0);
		boxh_tabs.layoutContents.set(6, boxh_tabs_l6);

		var btnFreeHand:PngButton = new PngButton(
			Style.TYPE_FREEHAND, 
			"assets/btn_freehand_cold.png", 
			"assets/btn_freehand_hot.png"
		);
		btnGpManager.add(btnFreeHand, true);
		boxh_tabs_l1.setItem(btnFreeHand);
		addChild(btnFreeHand);

		var btnShape:PngButton = new PngButton(
			Style.TYPE_SHAPE, 
			"assets/btn_shape_cold.png", 
			"assets/btn_shape_hot.png"
		);
		btnGpManager.add(btnShape, false);
		boxh_tabs_l2.setItem(btnShape);
		addChild(btnShape);

		var btnText:PngButton = new PngButton(
			Style.TYPE_TEXT, 
			"assets/btn_text_cold.png", 
			"assets/btn_text_hot.png"
		);
		btnGpManager.add(btnText, false);
		boxh_tabs_l3.setItem(btnText);
		addChild(btnText);

		var btnFillColor:PngButton = new PngButton(
			'fillColor', 
			"assets/btn_fillColor_cold.png", 
			"assets/btn_fillColor_hot.png"
		);

		btnGpManager.add(btnFillColor, false);
		boxh_tabs_l4.setItem(btnFillColor);
		addChild(btnFillColor);

		var btnStrokeColor:PngButton = new PngButton(
			'strokeColor', 
			"assets/btn_strokeColor_cold.png", 
			"assets/btn_strokeColor_hot.png"
		);

		btnGpManager.add(btnStrokeColor, false);
		boxh_tabs_l5.setItem(btnStrokeColor);
		addChild(btnStrokeColor);

		pnShape = new PanelShapeEditor( layoutContentForPanel, this);
		pnTextEditor = new PanelTextEditor(layoutContentForPanel, this);
		pnPalEditor = new PanelPaletteEditor(layoutContentForPanel, this);
		pnStrokeEditor = new PanelStrokeEditor(layoutContentForPanel, this);
		pnFreeHand = new PanelFreeHandEditor(layoutContentForPanel, this);
		
		pnShape.setVisible(false);
		pnTextEditor.setVisible(false);
		pnPalEditor.setVisible(false);
		pnStrokeEditor.setVisible(false);

		canvas.setActiveStyle(styFreeHand);
		setTitle("Style Editor - freeHand");
	}

	public override function updateProperties(): Void {
		btnGpManager.select(canvas.getActiveStyle().getType());
	}

	public function getContainer(): Sprite {
		return cast (this, Sprite);
	}

	public function updateForeColor(cl:Int): Void {
		cast (canvas.getActiveStyle(), Style).getStrokeProperty().setColor(cl);
		if (Std.is(canvas.getActiveStyle(), TextStyle)) {
			var t:TextStyle = cast (canvas.getActiveStyle(), TextStyle);
			t.updateTextStyle(t.getIsBold());
		}
	}

	public function updateForeColorAlpha(value:Float): Void {
		cast (canvas.getActiveStyle(), Style).getStrokeProperty().setTransparency(value);
	}

	public function updateBackColor(cl:Int): Void {
		var sty:Style = cast(canvas.getActiveStyle(), Style);
		sty.setFillProperty(new Fill(sty,  cl , 1.0));
	}

	public function updateBackColorAlpha(value:Float): Void {

		var sty:Style = cast(canvas.getActiveStyle(), Style);
		sty.getFillProperty().setTransparency(value);
	}

	public override function handleEvent(name:String, obj:Dynamic, data:Dynamic): Void {
		super.handleEvent(name, obj, data);
		switch (name) {
			case ButtonGroupManager.EVT_SEL_CHANGE:
				selectTabByName(data);	 
		}
		
	}

	private function selectTabByName(name:String): Void {
		
		 if (name == Style.TYPE_FREEHAND) {
		 	canvas.setActiveStyle(styFreeHand);
		 	setTitle("Style Editor - freeHand");
		 	pnFreeHand.setVisible(true);
		 	pnShape.setVisible(false);
		 	pnTextEditor.setVisible(false);
		 	pnPalEditor.setVisible(false);
		 	pnStrokeEditor.setVisible(false);

		 } 
		 if (name == Style.TYPE_SHAPE) {
		 	canvas.setActiveStyle(styShape);
		 	setTitle("Style Editor - Shapes");
		 	if (! pnShapeInit) {
		 		pnShape.refresh(layoutContentForPanel.getInitialSize());
		 		pnShapeInit = true;
		 	}
		 	pnShape.setVisible(true);

		 	pnFreeHand.setVisible(false);
		 	pnTextEditor.setVisible(false);
		 	pnPalEditor.setVisible(false);
		 	pnStrokeEditor.setVisible(false);
		 }
		 if (name == Style.TYPE_TEXT) {
		 	canvas.setActiveStyle(styText);
		 	setTitle("Style Editor - Text");
		 	if (! pnTextInit) {
		 		pnTextEditor.refresh(layoutContentForPanel.getInitialSize());
		 		pnTextInit = true;
		 	}
		 	pnTextEditor.setVisible(true);

		 	pnFreeHand.setVisible(false);
		 	pnShape.setVisible(false);
		 	pnPalEditor.setVisible(false);
		 	pnStrokeEditor.setVisible(false);
		 }
		 if (name == 'fillColor') {
		 	if (! pnFillInit) {
		 		pnPalEditor.refresh(layoutContentForPanel.getInitialSize());
		 		pnFillInit = true;
		 	}
		 	setTitle("Style Editor, " + canvas.getActiveStyle().getType() + " fill color");
		 	pnPalEditor.setVisible(true);

		 	pnFreeHand.setVisible(false);
		 	pnShape.setVisible(false);
		 	pnTextEditor.setVisible(false);
		 	pnStrokeEditor.setVisible(false);
		 }
		 if (name == 'strokeColor') {
		 	if (! pnStrokeInit) {
		 		pnStrokeEditor.refresh(layoutContentForPanel.getInitialSize());
		 		pnStrokeInit = true;
		 	}
		 	setTitle("Style Editor, " + canvas.getActiveStyle().getType() + " stroke color");
		 	pnStrokeEditor.setVisible(true);

		 	pnFreeHand.setVisible(false);
		 	pnShape.setVisible(false);
		 	pnTextEditor.setVisible(false);
		 	pnPalEditor.setVisible(false);
		 }
	}
}