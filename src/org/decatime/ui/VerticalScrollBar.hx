package org.decatime.ui;

import flash.geom.Rectangle;
import flash.geom.Point;
import flash.display.Graphics;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.geom.Matrix;

import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.events.IObserver;
import org.decatime.events.IObservable;

class VerticalScrollBar extends BaseScrollBar implements IObserver {
	private static var THGAP:Int = 2;
	private var currStep:Float;
	private var stepCount:Float;
	private var stepSize:Float;
	private var shUp:BaseShapeElement;
	private var shDown:BaseShapeElement;
	private var shThumb:BaseShapeElement;
	private var layoutScrollUp:LayoutContent;
	private var layoutScArea:LayoutContent;
	private var layoutScrollDown:LayoutContent;
	private var layoutCreated:Bool;
	private var list:BrowseForFileList;
	private var scTotalHeight:Float;
	private var startY:Float;
	private var flagDir:Float;
	private var initialPos:Float;

	public function new(name:String, parentLayout:LayoutContent, bfileList:BrowseForFileList) {
		super(name, parentLayout);
		this.list = bfileList;
		currStep = 0;
		stepCount = 0;
		stepSize = 0;
		initialPos = 0;

		shUp = new BaseShapeElement('shUp');
		shDown = new BaseShapeElement('shDown');
		shThumb = new BaseShapeElement('ShThumb');

	}

	public override function refresh(r:Rectangle): Void {
		super.refresh(r);
		this.graphics.lineStyle(4, 0xa1a1a1, 0.9);
		this.graphics.drawRect(r.x, r.y, r.width, r.height);

	}

	public function synchronize(): Void {
		if (! layoutCreated) {
			createLayout();
			layoutCreated = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMeMouseDown);
			parentLayout.refresh(parentLayout.getInitialSize());
		}
		drawThumbPos();
	}

	private function canStepUp(?size:Int = 1): Bool {
		return list.getFirstVisible() - size > -1;
	}

	private function stepUp(?size:Int = 1): Void {
		list.setFirstVisible(list.getFirstVisible() - size, false);
		shThumb.y -= (stepSize * size);
	}

	private function canStepDown(?size:Int = 1): Bool {
		return list.getFirstVisible() <= list.getListCount() - list.getNbVisible() - size;
	}

	private function stepDown(?size:Int = 1): Void {
		list.setFirstVisible(list.getFirstVisible() + size, false);
		shThumb.y += (stepSize * size);
	}

	private function onMeMouseDown(e:MouseEvent): Void {
		var objs:Array<DisplayObject> = this.getObjectsUnderPoint(new Point(e.stageX, e.stageY));
		if (objs.length == 2) {
			if (Std.is(objs[1], Shape)) {
				var sh:Shape = cast(objs[1], Shape);
				if (sh.name == 'shUp') {
					if (canStepUp()) {
						stepUp();
					}
				} else if (sh.name == 'shDown') {
					if (canStepDown()) {
						stepDown();
					}
				} else {
					if (e.localY > shThumb.y && e.localY < shThumb.y + shThumb.height) {
						startY = e.stageY - shThumb.y;
						flagDir = startY;
						this.addEventListener(MouseEvent.MOUSE_UP, onMeMouseUp);
						this.addEventListener(MouseEvent.MOUSE_OUT, onMeMouseUp);
						this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
					} else if (e.localY > shUp.y + shUp.height && e.localY < shThumb.y + shThumb.height) {
						if (canStepUp()) {
							stepUp();
						}
					}
					if (e.localY > shThumb.y + shThumb.height && e.localY < shDown.y) {
						if (canStepDown()) {
							stepDown();
						}
					}
				}
			}
		} else if (objs.length == 1) {
			// click outside of the thumb and the arrows but in the thumb area
			if (e.localY > shUp.y + shUp.height && e.localY < shThumb.y + shThumb.height) {
				if (canStepUp(list.getNbVisible())) {
					stepUp(list.getNbVisible());
				}
			}
			if (e.localY > shThumb.y + shThumb.height && e.localY < shDown.y) {
				if (canStepDown(list.getNbVisible())) {
					stepDown(list.getNbVisible());
				}
			}
		}
	}

	private function onEnterFrame(e:Event): Void {
		var newY:Float = this.stage.mouseY;
		if (flagDir > newY) {
			if (canStepUp()) {
				stepUp();
				flagDir = newY;
			} else {
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				shThumb.y = shUp.y + shUp.height + THGAP;
			}
		} else if (flagDir < newY) {
			if (canStepDown()) {
				stepDown();
				flagDir = newY;
			} else {
				if (canStepUp()) {
					stepUp();
				}
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				shThumb.y = shDown.y - (THGAP * 2) - shThumb.height;
			}
		}
	}

	private function moveThumb(ypos:Float): Float {
		var topValue:Float = shUp.y + shUp.height + THGAP;
		var bottomValue:Float = shDown.y - THGAP - shThumb.height;
		if (ypos < topValue) {
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			return topValue;
		}
		if (ypos > bottomValue) {
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			return bottomValue;
		}
		return ypos;
	}

	private function onMeMouseUp(e:MouseEvent): Void {
		this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	private function drawThumbPos(): Void {
		//trace ("drawing the thumb position");
		var n:Int = list.getListCount();      // number of list items
		var h:Int = list.getListItemHeight(); // item height
		var p:Int = list.getNbVisible();      // number of visible items per page
		var i:Int = list.getFirstVisible();   // first visible index

		var visibleHeight:Float = p * h;
		var totalHeight:Float = n * h;
		var thHeightPct:Float = (list.getNbVisible() * list.getListItemHeight()) / totalHeight;
		if (thHeightPct > 1) { thHeightPct = 1; }

		scTotalHeight = layoutScArea.getInitialSize().height - THGAP;
		var thHeight:Float = scTotalHeight * thHeightPct;
		var g:Graphics = shThumb.graphics;
		
		var amp:Float = scTotalHeight - thHeight; - THGAP;
		stepSize = amp / (list.getListCount() - list.getNbVisible());

		g.clear();
		var box:Matrix = new Matrix();
		box.createGradientBox(layoutScArea.getInitialSize().width, thHeight + THGAP);
		g.beginGradientFill(GradientType.LINEAR, [0x444444, 0xffffff], [1, 1], [1, 255], box);
		//g.beginFill(0xffffff, 1);
		g.drawRoundRect(THGAP, THGAP, shUp.width - (THGAP / 2), thHeight + THGAP, 8, 8);
		g.endFill();
		shThumb.y = shUp.y + shUp.height + THGAP;
	}

	private function createLayout(): Void {
		var bmain:BoxLayout = new BoxLayout(parentLayout, DirectionType.VERTICAL ,'vscrollLayout');
		bmain.addListener(this);
		bmain.hgap = 0;
		bmain.vgap = 0;

		layoutScrollUp = bmain.layoutContents.get(bmain.addLayoutContent(24));
		layoutScArea = bmain.layoutContents.get(bmain.addLayoutContent(1.0));
		layoutScrollDown = bmain.layoutContents.get(bmain.addLayoutContent(24));

		layoutScrollUp.setItem(shUp);
		layoutScrollDown.setItem(shDown);
		this.addChild(shUp);

		this.addChild(shDown);
		drawArrows();

		layoutScArea.setItem(shThumb);
		this.addChild(shThumb);
	}

	private function drawArrows(): Void {
		var box:Matrix = new Matrix();
		box.createGradientBox(20, 20);

		var g:Graphics = shUp.graphics;
		g.clear();
		
		g.beginGradientFill(GradientType.LINEAR, [0x444444, 0xffffff], [1, 1], [1, 255], box);
		//g.beginFill(0xa2a2a2, 1);
		g.moveTo(2, 20);
		g.lineTo(20, 20);
		g.lineTo(11, 2);
		g.lineTo(2, 20);
		g.endFill();

		g = shDown.graphics;
		g.clear();
		g.beginGradientFill(GradientType.LINEAR, [0x444444, 0xffffff], [1, 1], [1, 255], box);
		//g.beginFill(0xa2a2a2, 1);
		g.moveTo(2, 2);
		g.lineTo(20, 2);
		g.lineTo(11, 20);
		g.lineTo(2, 2);
		g.endFill();

		

	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic): Void {
		switch(name) {
			case BoxLayout.EVT_REFRESH_DONE:
				
		}
	}

	public function getEventCollection(): Array<String> {
		return [BoxLayout.EVT_REFRESH_DONE];
	}
}