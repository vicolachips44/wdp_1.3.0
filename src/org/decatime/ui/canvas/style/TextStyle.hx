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
 
package  org.decatime.ui.canvas.style;

import flash.display.DisplayObject;
import flash.filters.BitmapFilter;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.display.Graphics;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.display.DisplayObjectContainer;
import flash.text.TextFormatAlign;
import flash.text.TextFieldType;
import flash.events.TextEvent;
import flash.events.Event;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.display.Sprite;
import flash.Lib;
import flash.utils.Timer;
import flash.events.TimerEvent;

import org.decatime.ui.canvas.IFilter;
import org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import org.decatime.ui.canvas.remote.CmdParser;
import org.decatime.events.IObserver;
import org.decatime.events.IObservable;

import openfl.Assets;
import flash.text.TextFormat;

class TextStyle extends Style {
	private var textField:TextField;
	private var imgText:BitmapData;
	private var bmptext:Bitmap;
	private var bIsReady:Bool;
	private var format:TextFormat;
	private var fontRes:String;
	private var isBold:Bool;
	private var tfInitValue:String;
	private var textFieldContainer:Sprite;
	private var tmDrawText:Timer;

	public function new(dobj:RemoteDrawingSurface, fontRes:String, ?stroke:Stroke) {
		super (dobj, stroke);

		strokeProperty.setSize(20); // default stroke property for text

		blnNeedFeedBack = false;
		bIsReady = false;
		this.fontRes = fontRes;
		tfInitValue = ' ';
		tmDrawText = new Timer(10);
		tmDrawText.addEventListener(TimerEvent.TIMER, onTmDrawTextEllapsed);
		createTextField();
	}

	public function getTextField(): TextField {
		return textField;
	}

	public function getTextFieldContainer(): Sprite {
		return textFieldContainer;
	}

	private function createTextField(): Void {
		textField = new TextField();

		textField.selectable = true;
		textField.mouseEnabled = true;
		textField.multiline = true;
		textField.wordWrap = true;
		textField.autoSize = TextFieldAutoSize.LEFT;
		textField.type = TextFieldType.INPUT;
		textField.border = true;
		textField.text = tfInitValue;
		textField.borderColor = 0x000000;

		textField.x = 0;
		textField.y = 0;

		textFieldContainer = new Sprite();
		textFieldContainer.buttonMode = true;

		textFieldContainer.addChild(textField);
		textFieldContainer.addEventListener(Event.ADDED_TO_STAGE, ontxtFieldAddedToStage);
		if (surface != null) {
			surface.parent.addChild(textFieldContainer);	
		}
	}

	private function ontxtFieldAddedToStage(e:Event): Void {
		textFieldContainer.removeEventListener(Event.ADDED_TO_STAGE, ontxtFieldAddedToStage);
		textFieldContainer.visible = false;

		bIsReady = false;
	}

	public function setFontRes(value:String): Void {
		fontRes = value;
	}

	public override function cleanUp(): Void {
		if (textFieldContainer.visible) {
			if (textField.text != tfInitValue) {
				finalize(null, 0, 0);
			} else {
				textFieldContainer.visible = false;
			}
		}
		bIsReady = false;
		surface.processEnd(0, 0);
	}

	public function getIsBold(): Bool {
		return isBold;
	}

	public function updateTextStyle(isBold:Bool): Void {
		var font = Assets.getFont (fontRes);
		if (font != null) {
			if (this.getStrokeProperty() == null) {
				this.setStrokeProperty(new Stroke(this, 0x000000 , 1.0 , 24 ));
			}
			
			format = new TextFormat(
				font.fontName, 
				this.getStrokeProperty().getSize(), 
				this.getStrokeProperty().getColor()
			);
			this.isBold = isBold;
			format.bold = isBold;

			textField.embedFonts = true;

			textField.defaultTextFormat = format;
			textField.setTextFormat(format);
		} else {
			//trace ("WARNING: Font " + fontRes + " was not loaded");
		}
		Facade.doBroadCast(this.getRemoteStruct());
	}

	public override function prepare(g:Graphics, xpos:Float, ypos: Float): Void {

		if (textFieldContainer.visible && textField.text != tfInitValue) {
			finalize(null, 0, 0);
			return;
		}

		startX = xpos;
		startY = ypos;

		textFieldContainer.visible = true;
		textField.text = tfInitValue;
		
		surface.parent.setChildIndex(textFieldContainer, surface.numChildren -1);

		textFieldContainer.x = startX  + surface.getInitialSize().x;
		textFieldContainer.y = startY  + surface.getInitialSize().y;
		textField.width = surface.width - startX;
		textField.x = 0;
		textField.border = true;

		updateTextStyle(this.isBold);
		
		textField.setSelection(1 , 1);
		textFieldContainer.stage.focus = textField;
		textField.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

		var msg:String = "" + (xpos) + "," + (ypos) + "";
		Facade.doBroadCast(CmdParser.CMD_START + CmdParser.CMD_SUFFIX + msg);
	}

	public function setText(text:String): Void {
		textField.text = text;
		// doBroadCast();
	}

	private function doBroadCast(): Void {
		var strB:StringBuf = new StringBuf();
		strB.add(CmdParser.CMD_CAR);
		strB.add(CmdParser.CMD_SUFFIX);
		strB.add(textField.text);
		Facade.doBroadCast(strB.toString());
	}
	
	private function onKeyUp(e:KeyboardEvent): Void {
		// doBroadCast();
	}

	public function finalizeText(): Void {
		bIsReady = false;
		#if flash
		surface.stage.focus = surface;
		#end
		textField.border = false;
		Lib.stage.focus = Facade.getInstance().getRoot();

		textField.text = StringTools.rtrim(StringTools.ltrim(textField.text));
		textField.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);

		drawText();
		doBroadCast();
		Facade.doBroadCast(CmdParser.CMD_END + CmdParser.CMD_SUFFIX + "");
		textField.text = tfInitValue;
		textFieldContainer.visible = false;
		
		// tmDrawText.start();
	}

	private function onTmDrawTextEllapsed(e:TimerEvent): Void {
		// tmDrawText.stop();

		
	}

	private function drawText(): Void {
		if (textField.text.length == 0) { 
			return; 
		}
		
		imgText = new BitmapData(
			Std.int(textField.width), 
			Std.int(textField.height), 
			true, 
			0x000000
		);

		imgText.draw(textField);
		if (surface.getActiveFilterAy() != null) {
			var filters:Array<Dynamic> = surface.getActiveFilterAy();

			var i:Int = 0;
			for (i in 0...filters.length) {
				imgText.applyFilter(
					imgText,
					imgText.rect,
					new Point(0, 0),
					filters[i]
				);
			}
		}
		
		var data:BitmapData = surface.getBmdCache();

		var mat:Matrix = new Matrix();
    	mat.translate(startX,startY);
    	
		data.draw(imgText,  mat);

		surface.updateUndoRedoHistory();
	}

	public override function finalize(g:Graphics, xpos:Float, ypos: Float): Void {
		finalizeText();
	}

	public override function draw(g:Graphics, xpos:Float, ypos: Float): Void {
		// nothing to do actually
	}

	public override function getRemoteStruct(): String {
		var strB:StringBuf = new StringBuf();
		strB.add(CmdParser.CMD_STY);
		strB.add(CmdParser.CMD_SUFFIX);
		strB.add(CmdParser.CMD_TYPE);
		strB.add(CmdParser.PROP_EQ);
		strB.add(CmdParser.TX_TYPE);
		strB.add(CmdParser.STY_SEP);
		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.FRES);
		strB.add(CmdParser.PROP_EQ);
		strB.add(fontRes);
		strB.add(CmdParser.PROP_SEP);
		strB.add(CmdParser.TX_BOLD);
		strB.add(CmdParser.PROP_EQ);
		strB.add(isBold);
		return strB.toString() + super.getRemoteStruct();
	}

	public override function getType(): String {
		return Style.TYPE_TEXT;
	}
}