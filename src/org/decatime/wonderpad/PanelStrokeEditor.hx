package org.decatime.wonderpad;

import flash.display.DisplayObject;

import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.IVisualElement;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.wonderpad.App;
import org.decatime.ui.canvas.style.Style;

class PanelStrokeEditor extends BoxLayout implements IObserver {
	private var parent:PopupStyleEditor;
	private var app:App;
	private var pnColor:PanelColorProperty;

	public function new(e:IVisualElement, parent:PopupStyleEditor) {
		super(e, DirectionType.VERTICAL, 'PanelStrokeEditor');
		this.parent = parent;
		initialize();
		app = cast(Facade.getInstance().getRoot(), App);
		app.canvas.addListener(this);
	}

	private function initialize(): Void {
		layoutContents.set(1, new LayoutContent(this, 1.0));

		pnColor = new PanelColorProperty( 
			layoutContents.get(1), 
			this.parent 
		);
		pnColor.targetType = PanelColorProperty.STROKE;
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic) {
		if (name == DrawingSurface.EVT_STYLE_CHANGED) {
			var sty:Style = cast(app.canvas.getActiveStyle(), Style);

			// updating the stroke color grid
			var element:IVisualElement = pnColor.getGridColor().getCellByColor(sty.getStrokeProperty().getColor());
			if (element != null) {
				pnColor.getGridColor().setSelected(element);
			}

			// updating the alpha value for this style
			pnColor.getAlphaSlider().setValue(sty.getStrokeProperty().getTransparency());
			
		}
	}

	public function getEventCollection(): Array<String> {
		return [
			DrawingSurface.EVT_STYLE_CHANGED
		];
	}
}