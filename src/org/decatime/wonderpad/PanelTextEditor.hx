package org.decatime.wonderpad;

import flash.display.DisplayObject;

import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.IVisualElement;
import org.decatime.Facade;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.ui.RadioButtonGroup;
import org.decatime.ui.RadioButton;
import org.decatime.ui.CheckBox;
import org.decatime.ui.BaseSlider;
import org.decatime.ui.HSlider;
import org.decatime.ui.canvas.style.TextStyle;

class PanelTextEditor extends BoxLayout implements IObserver {

	private var parent:PopupStyleEditor;
	private var canvas:DrawingSurface;
	private var app:App;
	private var hsTransparencyLevel: HSlider;
	private var isBold:Bool;
	private var isItalic:Bool;

	public function new(e:IVisualElement, parent:PopupStyleEditor) {
		super(e, DirectionType.HORIZONTAL, 'PanelTextEditorVBox');
		this.parent = parent;
		this.vgap = 16;
		app = cast (Facade.getInstance().getRoot(), App);
		canvas = app.canvas;
		isBold = false;
		isItalic = false;
		initialize();
	}

	private function initialize(): Void {
		this.layoutContents.set(1, new LayoutContent(this, 150));
		this.layoutContents.set(2, new LayoutContent(this, 1.0));

		var bVertOptions:BoxLayout = new BoxLayout(this.layoutContents.get(1), DirectionType.VERTICAL, 'bVertOptions');
		bVertOptions.hgap = 0;
		bVertOptions.vgap = 3;

		bVertOptions.layoutContents.set(1, new LayoutContent(bVertOptions, 24));

		bVertOptions.layoutContents.set(2, new LayoutContent(bVertOptions, 24));

		bVertOptions.layoutContents.set(3, new LayoutContent(bVertOptions, 24));
		bVertOptions.layoutContents.set(4, new LayoutContent(bVertOptions, 24));
		bVertOptions.layoutContents.set(5, new LayoutContent(bVertOptions, 24));
		bVertOptions.layoutContents.set(6, new LayoutContent(bVertOptions, 1.0));

		var rdbGroup:RadioButtonGroup = new RadioButtonGroup('fonts');
		rdbGroup.addListener(this);
		createRdb(bVertOptions.layoutContents.get(1), 'rdbFontLcd', 'Lcd font', true, rdbGroup);
		createRdb(bVertOptions.layoutContents.get(2), 'rdbVera', 'Vera', false, rdbGroup);
		createRdb(bVertOptions.layoutContents.get(3), 'rdbPepa', 'BepaOblique', false, rdbGroup);
		createRdb(bVertOptions.layoutContents.get(4), 'rdb1979', '1979 font', false, rdbGroup);
		createRdb(bVertOptions.layoutContents.get(5), 'rdbVeraMono', 'Vera Mono', false, rdbGroup);

		var bVertChks:BoxLayout = new BoxLayout(this.layoutContents.get(2), DirectionType.VERTICAL, 'bVertChks');
		bVertChks.layoutContents.set(1, new LayoutContent(bVertChks, 24));

		createChk(bVertChks.layoutContents.get(1), 'chkBolx', ' Bold ?', false);

		hsTransparencyLevel = new WpHSlider('hsFontSize', bVertOptions.layoutContents.get(6) , this.parent);
		hsTransparencyLevel.setMinValue(12);
		hsTransparencyLevel.setMaxValue(96);
		hsTransparencyLevel.setLabel('Size: ');
		hsTransparencyLevel.setValue(20);
		hsTransparencyLevel.pack();
		hsTransparencyLevel.addListener(this);
	}

	private function createChk(
		lcontent:LayoutContent, 
		name:String, 
		label:String, 
		selected:Bool
	) {
		var boxChk:BoxLayout = new BoxLayout( 
			lcontent, 
			DirectionType.HORIZONTAL,
			name
		);
		boxChk.hgap = 0;
		boxChk.vgap = 0;

		boxChk.layoutContents.set(1, new LayoutContent(boxChk, 120));
		boxChk.layoutContents.get(1).drawBorder = false;

		var chk:CheckBox = new CheckBox(name, label);
		parent.addChild(chk);
		boxChk.layoutContents.get(1).setItem(chk);
		chk.setSelected(selected);
		chk.addListener(this);
	}

	private function createRdb(
		lcontent:LayoutContent, 
		name:String, 
		label:String, 
		selected:Bool, 
		rdbGroup:RadioButtonGroup
	) {
		var rdb:RadioButton = new RadioButton(name, rdbGroup, label);
		parent.addChild(rdb);
		lcontent.setItem(rdb);
		rdb.setSelected(selected);
	}

	public function getEventCollection():Array<String> {
		return [
			BaseSlider.EVT_VALUE_CHANGED, 
			RadioButtonGroup.EVT_RDB_CLICK, 
			CheckBox.EVT_CHK_CLICK
		];
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic) {
		var sty:TextStyle = this.parent.getStyText();

		if (name == BaseSlider.EVT_VALUE_CHANGED) {
			var newValue:Float = data;
			var sValue:String = Std.string(Math.round(newValue));
			sty.getStrokeProperty().setSize(Math.round(newValue));
			sty.updateTextStyle(isBold);
		}

		if (name == RadioButtonGroup.EVT_RDB_CLICK) {
			switch (data) {
				case 'rdbFontLcd':
					sty.setFontRes( 'assets/lcd.ttf' );
				case 'rdbVera':
					sty.setFontRes( 'assets/Vera.ttf' );
				case 'rdbPepa':
					sty.setFontRes( 'assets/BepaOblique.ttf' );
				case 'rdb1979':
					sty.setFontRes( 'assets/1979rg.ttf' );
				case 'rdbVeraMono':
					sty.setFontRes( 'assets/VeraMono.ttf' );
			}
		}
		
		if (name == CheckBox.EVT_CHK_CLICK) {
			isBold = data;
		}

		sty.updateTextStyle(isBold);
	}
}