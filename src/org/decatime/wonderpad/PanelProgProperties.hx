package org.decatime.wonderpad;

import flash.geom.Rectangle;

import org.decatime.ui.BaseVisualElement;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.layouts.LayoutContent;
import org.decatime.ui.Label;

class PanelProgProperties extends BaseInnerPanel {
	
	public function new() {
		super();
	}

	private override function getPanelTitle():String {
		return 'Wonderpad properties';
	}
}