package org.decatime.wonderpad;

import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;

import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.RadioButtonGroup;
import org.decatime.ui.RadioButton;
import org.decatime.ui.IVisualElement;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.ui.BaseSlider;
import org.decatime.ui.HSlider;
import org.decatime.Facade;
import org.decatime.ui.canvas.style.FreeHand;
import org.decatime.ui.canvas.style.Style;

class PanelFreeHandEditor extends BoxLayout implements IObserver {
	private var parent:PopupStyleEditor;
	private var canvas:DrawingSurface;
	private var hsStrokeSize:HSlider;
	private var app:App;
	private var sty:FreeHand;
	private var pnColorProp:PanelColorProperty;
	private var rdbGroup:RadioButtonGroup;

	public function new(e:IVisualElement, parent:PopupStyleEditor) {
		super(e, DirectionType.VERTICAL, 'PanelFreeHandVBox');
		this.parent = parent;
		this.vgap = 16;
		this.hgap = 4;
		app = cast (Facade.getInstance().getRoot(), App);
		canvas = app.canvas;
		initialize();
	}

	private function initialize(): Void {
		layoutContents.set(1, new LayoutContent(this, 30));
		layoutContents.set(2, new LayoutContent(this, 30));
		layoutContents.set(3, new LayoutContent(this, 30));
		layoutContents.set(4, new LayoutContent(this, 60)); // SpinButton container


		rdbGroup = new RadioButtonGroup('brushes');
		rdbGroup.addListener(this);

		createRdb(layoutContents.get(1), 'rdbBrushLine', 'Line brush', true, rdbGroup);
		createRdb(layoutContents.get(2), 'rdbBrushRound', 'Round brush', false, rdbGroup);
		createRdb(layoutContents.get(3), 'rdbBrushSquare', 'Square brush', false, rdbGroup);

		hsStrokeSize = new WpHSlider('hsStrokeSize', layoutContents.get(4), this.parent);
		hsStrokeSize.setMinValue(1);
		hsStrokeSize.setMaxValue(50);
		hsStrokeSize.setValue(3);
		hsStrokeSize.setLabel('Size:');
		hsStrokeSize.pack();
		hsStrokeSize.addListener(this);
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

	public function handleEvent(name:String, sender:IObservable, data:Dynamic) {
		if (canvas.getActiveStyle().getType() == Style.TYPE_FREEHAND) {
			sty = cast(canvas.getActiveStyle(), FreeHand);
			if (name == BaseSlider.EVT_VALUE_CHANGED) {
				sty.getStrokeProperty().setSize(data);
			} else if (name == RadioButtonGroup.EVT_RDB_CLICK) {
				switch (data) {
					case 'rdbBrushLine':
						sty.setBrushType(FreeHand.BRUSH_LINE);
					case 'rdbBrushRound':
						sty.setBrushType(FreeHand.BRUSH_ROUND);
					case 'rdbBrushSquare':
						sty.setBrushType(FreeHand.BRUSH_SQUARE);
				}
			}
		}
	}

	public function getEventCollection(): Array<String> {
		return [
			BaseSlider.EVT_VALUE_CHANGED,
			RadioButtonGroup.EVT_RDB_CLICK,
			DrawingSurface.EVT_STYLE_CHANGED
		];
	}
}