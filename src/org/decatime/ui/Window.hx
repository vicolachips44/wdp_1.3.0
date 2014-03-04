/* 
 * Copyright (C)2012-2013 decatime.org
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a 
 * copy of this software and associated documentation files (the "Software"), 
 * to deal in the Software without restriction, including without limitation 
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 * and/or sell copies of the Software, and to permit persons to whom the 
 * Software is furnished to do so, subject to the following conditions: 
 * 
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software. 
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE. 
 */
 
package org.decatime.ui;

import openfl.Assets;

import flash.Lib;
import flash.display.Sprite;
import flash.display.Shape;
import flash.filters.BlurFilter;
import flash.filters.BitmapFilter;
import flash.display.GradientType;
import flash.filters.DropShadowFilter;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormatAlign;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Rectangle;

import org.decatime.layouts.LayoutContent;
import org.decatime.ui.IVisualElement;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.DirectionType;
import org.decatime.events.IObservable;
import org.decatime.events.IObserver;
import org.decatime.Facade;

class Window extends BaseVisualElement implements IObserver {
	private var title:String;
	private var position:Rectangle;
	private var gripBar:Shape;
	private var btnSpriteClose:Sprite;
	private var textTitle:TextField;
	private var format:TextFormat;
	private var titleFont:String;
	private var startX:Float;
	private var startY:Float;
	private var clientArea:LayoutContent;
	private var owner:IVisualElement;
	private var layout:BoxLayout;
	private var isInitialized:Bool;
	private var horizontalGap:Int;
	private var verticalGap:Int;
	private var modalMask:Sprite;

	public function new(n:String, title:String, owner:IVisualElement) {
		super(n);
		this.title = title;

		// default size of window
		position = new Rectangle(0, 0, 320, 320);
		this.buttonMode = false;
		this.owner = owner;
		isInitialized = false;
		horizontalGap = 4;
		verticalGap = 4;

		Facade.getInstance().addListener(this);
		createLayout();
	}

	public function getHorizontalGap(): Int {
		return horizontalGap;
	}
	public function setHorizontalGap(value:Int): Void {
		horizontalGap = value;
	}

	public function getVerticalGap(): Int {
		return verticalGap;
	}
	public function setVerticalGap(value:Int): Void {
		verticalGap = value;
	}

	public override function refresh(r:Rectangle): Void {
		var clRect = getThisRect(r);
		if (! isInitialized) {
			initializeComponent(clRect);
			clientArea.refresh(clRect);
			updateProperties();
		}
	}

	private function getThisRect(r:Rectangle): Rectangle {
		var clRect:Rectangle = r;
		clRect.y = gripBar.height + verticalGap;
		clRect.height = position.height - (gripBar.height + (verticalGap * 2));
		clRect.width = width - (horizontalGap * 2);
		clRect.x = verticalGap;
		return clRect;
	}

	private function updateProperties(): Void {
		//trace ("WARNING: This method must be overrided in order to refresh the properties of the window");
	}

	private function initializeComponent(r:Rectangle): Void {
		//trace ("WARNING: initializeComponent method should be overrided to create the components");
	}

	public function getClientArea(): LayoutContent {
		return clientArea;
	}

	public function setTitle(title:String): Void {
		textTitle.text = title;
		textTitle.setTextFormat(format);
	}

	public function show(args:Dynamic) {
		if (isModal()) {
			createMask();
		}
		
		if (! Lib.stage.contains(this)) {
			Lib.stage.addChild(this);
			initializePopup();
			setPopupPosition();
			this.refresh(position);
			isInitialized = true;
		} else {
			// bring it to front
			Lib.stage.setChildIndex(this, Lib.stage.numChildren -1);
			this.updateProperties();
			this.visible = true;
		}
	}

	public function close() {
		if (Lib.stage.contains(this)) {
			this.visible = false;
			if (isModal()) {
				Lib.stage.removeChild(modalMask);
				modalMask = null; // dispose the modal mask object
			}
		}
	}

	public function isModal(): Bool {
		return false;
	}

	private function createMask(): Void {
		modalMask = new Sprite();
		modalMask.addEventListener(Event.ADDED_TO_STAGE, onMaskAddedToStage);
		Lib.stage.addChild(modalMask);
	}

	private function onMaskAddedToStage(e:Event): Void {
		modalMask.graphics.clear();
		modalMask.graphics.beginFill(0x000000, 0.3);
		var r:Rectangle = Facade.getInstance().getStageRect();
		modalMask.graphics.drawRect(r.x, r.y, r.width, r.height);
		modalMask.graphics.endFill();
	}

	private function createClientArea(clientArea:LayoutContent): Void {
		//trace ("WARNING: this method must be overrided in order to create the client area layout content");
	}

	private function createLayout(): Void {
		layout = new BoxLayout(this, DirectionType.VERTICAL, 'popupItem_defaultBoxLayout');
		layout.addListener(this);
		layout.layoutContents.set(1, new LayoutContent(layout, 36));

		clientArea = new LayoutContent(layout, 1.0);

		layout.layoutContents.set(2, clientArea);
	}
	
	private function initializePopup() {
		if (! isInitialized) {
			drawWindowDecoration();
			createClientArea(clientArea);
			addListeners();
			
		}
	}

	private function setPopupPosition() {
		// by default the window is center on stage
		var w:Float = Lib.stage.stageWidth;
		var h:Float = Lib.stage.stageHeight;

		this.x = (w / 2) - (position.width / 2);
		this.y = (h / 2) - (position.height / 2);
	}

	private function drawWindowDecoration() {
		var box:Matrix = new Matrix();
	    gripBar = new Shape();
	    gripBar.name = "gripBar";
	    gripBar.graphics.lineStyle(1, 0x000000, 0.70);
	    box.createGradientBox(position.width, 32);
	    gripBar.graphics.beginGradientFill(GradientType.LINEAR, [0x444444, 0x999999], [1, 1], [1, 255], box);
	    gripBar.graphics.drawRect(1, 1, position.width - 4, 34);
	    gripBar.graphics.endFill();
	    var f:Array<BitmapFilter> = new Array<BitmapFilter>();
	    var blurFilter:BlurFilter = new BlurFilter(2, 2);
	    f.push(blurFilter);
	    var shadowFilter:DropShadowFilter = new DropShadowFilter(4, 45, 0x000000, 1, 4, 4, 1, 1, false, false, false);
	    f.push(shadowFilter);
	    gripBar.filters = f;
	    addChild(gripBar);

	    textTitle = new TextField();
	    textTitle.name = "popupTitle";
	    textTitle.text = title;
	    textTitle.selectable = false;
		textTitle.autoSize = TextFieldAutoSize.LEFT;
		textTitle.mouseEnabled = false;
		format = new TextFormat();
		if (titleFont != null) {
			var font = Assets.getFont (titleFont);
			if (font == null) {
				throw ("error while loading the popupitem font");
			}
			format = new TextFormat(font.fontName, 12, 0xf1f1f1);
			format.bold = true;	
		} else {
			format = new TextFormat(
				Facade.getInstance().getDefaultFont().fontName, 
				Facade.getInstance().getDefaultFontSize(), 
				0xf1f1f1
			);
			format.bold = true;
		}
		format.align = TextFormatAlign.CENTER;
		textTitle.x = 10;
		textTitle.y = 1;
		textTitle.setTextFormat(format);
		addChild(textTitle);

	    var borders:Shape = new Shape();
	    borders.name = "borders";
	    borders.graphics.lineStyle(2, 0x000000, 0.70);
	    borders.filters = f;
	    borders.graphics.drawRect(0, 0, position.width, position.height);
	    addChild(borders);

	    var claShape:Shape = new Shape();
	    claShape.name = "claShape";
	    claShape.graphics.clear();
	    claShape.graphics.beginFill(0xffffff, 1.0);
	    claShape.graphics.drawRect(2, 38, position.width - 4, position.height - 40);
	    claShape.graphics.endFill();
	    addChild(claShape);

	    btnSpriteClose = new Sprite();
	    var btnClose:Shape = new Shape();

        btnClose.name = "btnClose";
        btnClose.graphics.lineStyle(0, 0);
        box.createGradientBox(60, 60, 0, 0, 0);
        btnClose.graphics.beginFill(0x000000, 0.7);
        btnClose.graphics.drawCircle(14, 14, 14);
        btnClose.graphics.lineStyle(0, 0x000000, 0);
        btnClose.graphics.endFill();
        btnClose.graphics.beginFill(0xffffff, 1);
        btnClose.graphics.drawRect(4, 12, 20, 4);
        btnClose.graphics.drawRect(12, 5, 4, 20);
        btnClose.graphics.endFill();
        btnSpriteClose.addChild(btnClose);
        btnSpriteClose.x = position.width - 34;
        btnSpriteClose.y = 3;
        
    	addChild(btnSpriteClose);
    	var dropShadow:DropShadowFilter = new DropShadowFilter( 
    		8 , 
    		34 , 
    		0x000000 , 
    		0.7 , 
    		5 , 
    		5 ,
    		1 ,
    		6
    	);
    	var f2:Array<BitmapFilter> = new Array<BitmapFilter>();
    	f2.push(dropShadow);

		filters = f2;
	}

	private function addListeners(): Void {
		#if !android
    	addEventListener(MouseEvent.MOUSE_DOWN, onContainerMouseDown);
    	#else 
    	addEventListener(TouchEvent.TOUCH_BEGIN, onContainerTouchBegin);
    	#end
	}

	// Event Handlers
	#if android
	private function onContainerTouchBegin(e:TouchEvent) {
		if (btnSpriteClose.hitTestPoint(e.stageX, e.stageY)) {
			this.close();
			return;
		}
		this.parent.setChildIndex(this, this.parent.numChildren - 1);
		
		if (gripBar.hitTestPoint(e.stageX, e.stageY)) {
			startX = e.localX;
			startY = e.localY;

			addEventListener(TouchEvent.TOUCH_END, onContainerTouchEnd);
			addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		}
	}

	private function onTouchMove(e:TouchEvent) {
		if (! isInBound()) {
			onContainerTouchEnd(null);
			return; // not in bound so we leave the room :)
		}

		this.x = this.stage.mouseX - startX;
		this.y = this.stage.mouseY - startY;
	}

	private function onContainerTouchEnd(e:TouchEvent) {
		removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		removeEventListener(TouchEvent.TOUCH_END, onContainerTouchEnd);
	}

	#else
	private function onContainerMouseDown(e:MouseEvent) {
		if (btnSpriteClose.hitTestPoint(e.stageX, e.stageY)) {
			this.close();
			return; // no need to go further...
		}

		this.parent.setChildIndex(this, this.parent.numChildren - 1);

		if (gripBar.hitTestPoint(e.stageX, e.stageY)) {
			startX = e.localX;
			startY = e.localY;
			//trace("start points are for X: " + startX + " and for Y: " + startY);
			addEventListener(MouseEvent.MOUSE_UP, onContainerMouseUp);
			addEventListener(Event.ENTER_FRAME, onContainerEnterFrame);
		}
	}

	private function onContainerMouseUp(e:MouseEvent) {
		removeEventListener(Event.ENTER_FRAME, onContainerEnterFrame);
		removeEventListener(MouseEvent.MOUSE_UP, onContainerMouseUp);
	}

	private function onContainerEnterFrame(e:Event) {
		if (! isInBound()) {
			removeEventListener(Event.ENTER_FRAME, onContainerEnterFrame);
			removeEventListener(MouseEvent.MOUSE_UP, onContainerMouseUp);
			return; // not in bound so we leave the room :)
		}

		this.x = this.stage.mouseX - startX;
		this.y = this.stage.mouseY - startY;
	}

	#end

	public function handleEvent(name:String, sender:IObservable, data:Dynamic): Void {
		// if (this.parent == null) { 
		// 	return; 
		// }
		switch(name) {
			case Facade.EV_RESIZE:
				// FIXME : does not really work has expected... (better than nothing !)
				if (! isInBound()) {
					//trace ("i was replaced");
				}
			case BoxLayout.EVT_REFRESH_DONE:
				throw "you really came here !!";
		}
	}

	public function getEventCollection(): Array<String> {
		return [Facade.EV_RESIZE];
	}

	// Event Handlers - END

	private function isInBound(): Bool {
		if (owner == null) { 
			throw "owner instance is null";
			return false; 
		}
		var r:Rectangle = owner.getInitialSize();
		if (r == null) {
			//trace("WARNING the parent item rect is null");
			return false;
		}
		if (r.x > this.x) { 
			this.x = r.x + 2;
			return false; 
		}
		if (r.x + r.width < this.x + this.width) {
			this.x = r.x + r.width - this.width  - 2;
			return false;
		}
		if (r.y > this.y) {
			this.y = r.y + 2;
			return false;
		}
		if (r.y + r.height < this.y + this.height) {
			this.y = r.y + r.height - this.height - 2;
			return false;
		}
		return true;
	}
}