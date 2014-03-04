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
 
package org.decatime.ui.canvas;

import flash.display.Graphics; 
import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.PixelSnapping;
import flash.utils.ByteArray;
import flash.errors.Error;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.errors.Error;
import flash.geom.Rectangle;

import org.decatime.ui.IVisualElement;
import  org.decatime.events.IObservable;
import  org.decatime.events.IObserver;
import  org.decatime.events.EventManager;
import  org.decatime.ui.canvas.background.BaseBackGround;
import  org.decatime.ui.canvas.style.IDrawable;
import  org.decatime.ui.canvas.style.FreeHand;
import  org.decatime.ui.canvas.style.ShapeStyle;
import  org.decatime.ui.canvas.style.TextStyle;
import  org.decatime.ui.canvas.style.Stroke;
import  org.decatime.ui.canvas.style.Fill;
import  org.decatime.ui.canvas.style.Style;
import  org.decatime.ui.canvas.remote.Broadcaster;
import  org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import  org.decatime.ui.canvas.remote.CmdParser;

class DrawingSurface extends RemoteDrawingSurface implements IObservable {
	private static var NAMESPACE:String = " org.decatime.ui.canvas.DrawingSurface: ";

	public static var EVT_DATA_READY:String = NAMESPACE + "EVT_DATA_READY";
	public static var EVT_STYLE_CHANGED:String = NAMESPACE + "EVT_STYLE_CHANGED";
	public static var EVT_CURSOR_POS_CHANGED:String = NAMESPACE = "EVT_CURSOR_POS_CHANGED";
	public static var EVT_SURFACE_CLEARED:String = NAMESPACE + "EVT_SURFACE_CLEARED";
	

	private var evManager:EventManager;
	private var transparent:Bool;
	#if proversion
	private var gdLayer:GuideLayer;
	#end
	private var currPacket:StringBuf;
	public var showCursorPos:Bool;

	public function new(in_name:String) {
		super(in_name);
		transparent = false;
		showCursorPos = false;
		evManager = new EventManager(this);
		#if proversion
		gdLayer = new GuideLayer(this);
		#end
	}

	public override function undo(): Void {
		super.undo();
		Facade.getInstance().doBroadCast(CmdParser.CMD_UNDO + CmdParser.CMD_SUFFIX);
	}

	public override function redo(): Void {
		super.redo();
		Facade.getInstance().doBroadCast(CmdParser.CMD_REDO + CmdParser.CMD_SUFFIX);
	}

	public override function setActiveStyle(sty:IDrawable): Void {
		super.setActiveStyle(sty);
		if (mode == RemoteDrawingSurface.MODE_NORMAL) {
			Facade.doLog('setActiveStyle: Sending the activestyle flow to the broadcaster', this);
			Facade.getInstance().doBroadCast(activeStyle.getRemoteStruct());
			evManager.notify(EVT_STYLE_CHANGED, sty);
		}
	}

	private override function onFeedbackAddedToStage(e:Event): Void {
		super.onFeedbackAddedToStage(e);

		// create event listeners
		#if android
		addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
		addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		#else
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		#end
	}

	// Event handlers
	#if android
	private function onTouchDown(e:TouchEvent): Void {
		processDown(stage.mouseX, stage.mouseY);
	}
	private function onTouchMove(e:TouchEvent): Void {
		processMove(stage.mouseX, stage.mouseY);
	}
	private function onTouchEnd(e:TouchEvent): Void {
		processEnd(stage.mouseX, stage.mouseY);
	}
	private function onTouchOut(e:TouchEvent): Void {
		processEnd(stage.mouseX, stage.mouseY);
	}

	#else
	// EVENT NOT FOR ANDROID
	private function onMouseDown(e:MouseEvent): Void {
		processDown(stage.mouseX, stage.mouseY);
	}
	private function onMouseMove(e:MouseEvent): Void {
		processMove(stage.mouseX, stage.mouseY);
	}
	private function onMouseUp(e:MouseEvent): Void {
		processEnd(stage.mouseX, stage.mouseY);
	}
	private function onMouseOut(e:MouseEvent): Void {
		processEnd(stage.mouseX, stage.mouseY);
	}
	#end
	// Event handler END

	public override function processDown(xpos:Float, ypos:Float): Void {
		super.processDown(xpos, ypos);
		if (activeStyle == null) { return; }
		if (mode == RemoteDrawingSurface.MODE_NORMAL) {
			#if proversion
			gdLayer.clear();
			#end
			if (activeStyle.needsFeedBack()) {
				#if android
				addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
				addEventListener(TouchEvent.TOUCH_OUT, onTouchOut);
				#else
				addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				#end
			}
		}
	}

	public override function processMove(xpos:Float, ypos:Float): Void {
		var posX:Float = xpos - x;
		var posY:Float = ypos - y;
		if (mode == RemoteDrawingSurface.MODE_NORMAL) {
			var pt:Point = null;
			
			#if proversion
			if (activeStyle.needsXY()) {
				gdLayer.drawGuide(new Point(posX, posY));
			}
			if (showCursorPos) {
				if (this.backGround.getHasCustCoordinate()) {
					pt = this.backGround.translateCoordinate(posX, posY);
				} else {
					pt = new Point(posX, posY);
				}
			
			}
			#else
			var pt:Point = new Point(posX, posY);
			#end
			evManager.notify(EVT_CURSOR_POS_CHANGED, pt);
		}
		
		if (! canDraw) {return;}
		
		activeStyle.draw(drawingFeedback.graphics, posX, posY);

		hasChanged = true;
	}

	public override function processEnd(xpos:Float, ypos:Float): Void {
		super.processEnd(xpos, ypos);
		if (mode == RemoteDrawingSurface.MODE_NORMAL) {
			#if android
			removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			removeEventListener(TouchEvent.TOUCH_OUT, onTouchOut);
			#else
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			#end
			#if proversion
			gdLayer.clear();
			#end
		}
	}
	
	public override function updateUndoRedoHistory(): Void {
		super.updateUndoRedoHistory();
		evManager.notify(EVT_DATA_READY, this);
	}

	public function getByteArray(format:String):ByteArray {
		var img:BitmapData = new BitmapData(bmdCache.width, bmdCache.height, true , 0x000000);
		var retB:ByteArray = null;

		if (! transparent) {
			var sh:Shape = new Shape();
			sh.graphics.beginFill(0xffffff, 1);
			sh.graphics.drawRect(0, 0, img.width, img.height);
			sh.graphics.endFill();
			img.draw( sh );
		}

		if (backGround != null && backGround.getDoSave()) {
			var cb:BitmapData = new BitmapData( img.width , img.height , true , 0x000000);
			cb.draw(backGround);
			img.draw(cb);
			
			cb.dispose();
		}

		img.draw(  bmdCache );

		if (format == 'png') {
			#if !flash
			retB = img.encode("png");
			#else
			retB = lib.encode.PNGEncoder.encode(img);
			#end
		} else if (format == 'jpg') {
			#if !flash
			retB = img.encode('jpg');
			#else
			var jpgc:lib.encode.JPGEncoder = new lib.encode.JPGEncoder();
			retB = jpgc.encode(img);
			#end
		}

		img.dispose();
		return retB;
	}

	public override function clear() : Void {
		super.clear();
		evManager.notify(EVT_SURFACE_CLEARED, null);
	}

	private override function doRefresh(r:Rectangle, ?bIgnoreSizeInfo:Bool = false): Void {
		super.doRefresh(r, bIgnoreSizeInfo);
		Facade.doLog('in doRefresh of DrawingSurface - BEGIN', this);
		#if proversion
		this.gdLayer.clear();
		Facade.doLog('the coordinate layer has been cleared', this);
		#end
		
		if (mode == RemoteDrawingSurface.MODE_NORMAL) {
			Facade.getInstance().doBroadCast(CmdParser.CMD_CLEAR + CmdParser.CMD_SUFFIX);	
			Facade.doLog('the clear command has been broadcasted...', this);
		}
		Facade.doLog('raising event EVT_DATA_READY', this);
		evManager.notify(EVT_DATA_READY, this);
	}

	// IObservable implementation
	public function addListener(observer:IObserver): Void {
		evManager.addListener(observer);
	}
	public function removeListener(observer:IObserver): Void {
		evManager.removeListener(observer);
	}

	public function notify(name:String, data:Dynamic): Void {
		evManager.notify(name, data);
	}
	// IObservable implementation END
}