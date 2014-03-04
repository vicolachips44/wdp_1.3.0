package org.decatime.ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldType;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;
import flash.display.PixelSnapping;

class BitmapText {
	private var bmData:BitmapData;

	private function new() {
	}

	public static function getNew(
		size: Rectangle,
		position:Point,
		label:String,
		in_color:Int = 0x000000,
		?align:String = 'left'
	): BaseBmpElement {
		var tfield:TextField = new TextField();
		tfield.selectable = false;
		tfield.autoSize = TextFieldAutoSize.LEFT;
		tfield.mouseEnabled = false;
		tfield.text = label;

		var format:TextFormat = new TextFormat(
			Facade.getInstance().getDefaultFont().fontName, 
			Facade.getInstance().getDefaultFontSize(), 
			in_color,
			true
		);

		tfield.embedFonts = true;
		tfield.defaultTextFormat = format;
		tfield.setTextFormat(format);

		var bmdCache:BitmapData = new BitmapData(
			Std.int(size.width), 
			Std.int(size.height), 
			true, 
			0x000000
		);
		if (align == 'left') {
			bmdCache.draw(
				tfield,
				new Matrix(1, 0, 0 , 1 , 2, (size.height / 2) - (tfield.textHeight / 2)),  // add a two pixel margin
				null, 
				null, 
				null, 
				true 
			);
		} else if (align == 'center') {
			bmdCache.draw(
				tfield,
				new Matrix(1, 0, 0 , 1 , (size.width / 2) - (tfield.textWidth / 2), (size.height / 2) - (tfield.textHeight / 2)), 
				null, 
				null, 
				null, 
				true 
			);
		} else if (align== 'right') {
			bmdCache.draw(
				tfield,
				new Matrix(1, 0, 0 , 1 ,
					size.width - tfield.textWidth - 2, 
					(size.height / 2) - (tfield.textHeight / 2)), 
				null, 
				null, 
				null, 
				true 
			);
		}
		var bmText:BaseBmpElement = new BaseBmpElement( bmdCache , PixelSnapping.NEVER , false );
		bmText.name = label;
		bmText.x = size.left + position.x;
		bmText.y = size.y + position.y;

		return bmText;
	}
}