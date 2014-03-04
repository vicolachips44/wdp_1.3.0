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
import org.decatime.ui.canvas.style.ShapeStyle;

class PanelShapeEditor extends BoxLayout implements IObserver {
	private var parent:PopupStyleEditor;
	private var canvas:DrawingSurface;
	private var hsStrokeSize:HSlider;
	private var app:App;
	private var sty:ShapeStyle;
	private var pnColorProp:PanelColorProperty;

	public function new(e:IVisualElement, parent:PopupStyleEditor) {
		super(e, DirectionType.VERTICAL, 'PanelShapeEditor');
		this.parent = parent;
		this.vgap = 16;
		this.hgap = 4;
		app = cast (Facade.getInstance().getRoot(), App);
		canvas = app.canvas;

		initialize();
	}

	private function initialize(): Void {
		this.layoutContents.set(1, new LayoutContent(this, 30));
		this.layoutContents.set(2, new LayoutContent(this, 30));
		this.layoutContents.set(3, new LayoutContent(this, 30));
		this.layoutContents.set(4, new LayoutContent(this, 60)); // SpinButton container

		var rdbGroup:RadioButtonGroup = new RadioButtonGroup('brushes');
		rdbGroup.addListener(this);
		createRdb(this.layoutContents.get(1), 'rdbBrushLine', 'Line shape', true, rdbGroup);
		createRdb(this.layoutContents.get(2), 'rdbBrushRound', 'Circle shape', false, rdbGroup);
		createRdb(this.layoutContents.get(3), 'rdbBrushSquare', 'Square shape', false, rdbGroup);

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
		sty = cast(canvas.getActiveStyle(), ShapeStyle);
		if (name == BaseSlider.EVT_VALUE_CHANGING) {
			sty.getStrokeProperty().setSize(data);
		} else if (name == RadioButtonGroup.EVT_RDB_CLICK) {
			switch (data) {
				case 'rdbBrushLine':
					sty.setShapeType(ShapeStyle.SHAPE_LINE);
				case 'rdbBrushRound':
					sty.setShapeType(ShapeStyle.SHAPE_CIRCLE);
				case 'rdbBrushSquare':
					sty.setShapeType(ShapeStyle.SHAPE_SQUARE);
			}
		}
	}

	public function getEventCollection(): Array<String> {
		return [
			BaseSlider.EVT_VALUE_CHANGING,
			RadioButtonGroup.EVT_RDB_CLICK
		];
	}
}