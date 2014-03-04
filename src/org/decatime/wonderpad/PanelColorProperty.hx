package org.decatime.wonderpad;

import flash.display.DisplayObject;

import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.IVisualElement;
import org.decatime.utils.ColorPalette;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.ui.HSlider;
import org.decatime.ui.BaseVisualElement;
import org.decatime.Facade;
import org.decatime.layouts.GridBoxLayout;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.utils.HtmlColor;
import org.decatime.ui.BaseShapeElement;
import org.decatime.ui.BaseSlider;
import org.decatime.ui.canvas.style.Style;

class PanelColorProperty extends BoxLayout implements IObserver {
	public static var STROKE:String = "stroke";
	public static var FILL:String = "fill";

	private var canvas:DrawingSurface;
	private var gdColor:GridBoxLayout;
	private var hsTransparencyLevel: HSlider;
	private var app:App;
	private var parent:IColorPropertyHolder;
	public var targetType:String;


	public function new(e:IVisualElement, parent:IColorPropertyHolder) {
		super(e, DirectionType.VERTICAL, 'PanelShapeEditorVBox');

		app = cast(Facade.getInstance().getRoot(), App);
		this.parent = parent;
		this.canvas = app.canvas;
		targetType = FILL;
		initialize();
	}

	public function getGridColor(): GridBoxLayout {
		return gdColor;
	}

	public function getAlphaSlider(): HSlider {
		return hsTransparencyLevel;
	}

	private function initialize(): Void {
		var l1:LayoutContent = new LayoutContent(this, 1.0);
		this.layoutContents.set(1, l1);

		var l2:LayoutContent = new LayoutContent(this, 40);
		this.layoutContents.set(2, l2);

		gdColor = new GridBoxLayout(l1 , 'gboxColors' , 8 , 2 );
		gdColor.setDrawFill(true);
		gdColor.setRaiseClickOnCell(true);
		gdColor.addListener(this);

		parent.getContainer().addChild(getNewColor(1, "Black"));
		parent.getContainer().addChild(getNewColor(2, "Silver"));
		parent.getContainer().addChild(getNewColor(3, "Gray"));
		parent.getContainer().addChild(getNewColor(4, "White"));
		parent.getContainer().addChild(getNewColor(5, "Maroon"));
		parent.getContainer().addChild(getNewColor(6, "Red"));
		parent.getContainer().addChild(getNewColor(7, "Purple"));
		parent.getContainer().addChild(getNewColor(8, "Fuchsia"));

		parent.getContainer().addChild(getNewColor(9, "Green"));
		parent.getContainer().addChild(getNewColor(10, "Lime"));
		parent.getContainer().addChild(getNewColor(11, "Olive"));
		parent.getContainer().addChild(getNewColor(12, "Yellow"));
		parent.getContainer().addChild(getNewColor(13, "Navy"));
		parent.getContainer().addChild(getNewColor(14, "Blue"));
		parent.getContainer().addChild(getNewColor(15, "Teal"));
		parent.getContainer().addChild(getNewColor(16, "Aqua"));

		var bTransparency:BoxLayout = new BoxLayout( l2 , DirectionType.HORIZONTAL , 'transparencyBox' );
		var lt1:LayoutContent = new LayoutContent(bTransparency, 4);
		var lt2:LayoutContent = new LayoutContent(bTransparency, 1.0);
		bTransparency.layoutContents.set(1, lt1);
		bTransparency.layoutContents.set(2, lt2);

		hsTransparencyLevel = new WpHSlider('hsTransparencyLevel', lt2, this.parent.getContainer());
		hsTransparencyLevel.setNbDecimal(2);
		hsTransparencyLevel.setMinValue(0.0);
		hsTransparencyLevel.setMaxValue(1.0);
		hsTransparencyLevel.setValue(1.0);
		hsTransparencyLevel.setLabel('Alpha:');
		hsTransparencyLevel.pack();
		hsTransparencyLevel.addListener(this);
	}

	private function getNewColor(index:Int, colorName:String): BaseVisualElement {
		var c:HtmlColor = ColorPalette.getChart().byName(colorName);
		try {
			gdColor.layoutContents.get(index).borderColor = c.colorValue;
			gdColor.layoutContents.get(index).fillColor = c.colorValue;
			gdColor.layoutContents.get(index).drawFill = false;
			var s:BaseVisualElement = new BaseVisualElement(colorName);
			gdColor.layoutContents.get(index).setItem(s);
			return s;
		} catch (msg:String) {

		}
		return null;
		
	}

	public function getEventCollection(): Array<String> {
		return [
			BaseSlider.EVT_VALUE_CHANGED,
			GridBoxLayout.CELL_CLICK_EVT	
		];
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic) {
		var sty:Style = cast (canvas.getActiveStyle(), Style);
		if (name == BaseSlider.EVT_VALUE_CHANGED) {
			var newValue:Float = data;
			if (targetType == STROKE) {
				parent.updateForeColorAlpha(newValue);	
			} else {
				parent.updateBackColorAlpha(newValue);
			}
			
			var sValue:String = Std.string(Math.abs(newValue));
		}
		if (name == GridBoxLayout.CELL_CLICK_EVT) {
			var clValue:Int = ColorPalette.getChart().byName(data).colorValue;
			if (targetType == STROKE) {
				parent.updateForeColor(clValue);
			} else {
				parent.updateBackColor(clValue);
			}
		}
	}

	private function formatValue(s:String): String {
		if (s.length > 4) {
			return s.substr(0, 4);
		} else {
			if (s.indexOf('.') == -1) {
				return s + '.00';
			} else {
				return StringTools.rpad( s , "0" , 4 - s.length );
			}
		}
	}
}