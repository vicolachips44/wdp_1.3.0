package org.decatime.ui;

import flash.display.Shape;
import flash.display.Graphics;
import flash.display.GradientType;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.filters.DropShadowFilter;

import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;


class ShapeButton extends Shape {
	
	private var label:String;
	private var textColor:Int;
	private var gradientBegin:Int;
	private var gradientEnd:Int;
	private var btnSize:Rectangle;
	private var bmText:BaseBmpElement;
	public var bitmap:Bitmap;

	public function new(
		name:String, 
		label: String,
		tcolor:Int,
		gbegin:Int,
		gend:Int,
		bsize:Rectangle
	) {
		super();

		this.name = name;
		this.label = label;
		this.textColor = tcolor;
		this.gradientBegin = gbegin;
		this.gradientEnd = gend;
		this.btnSize = bsize;
		bmText = BitmapText.getNew(bsize, new Point(btnSize.x, btnSize.y), label, tcolor, 'center' );

		this.filters = [
			new DropShadowFilter(
			 	4 , // distance
			 	45 , //angle
			 	0x000000 , //color
			 	1 , //alpha
			 	6 , //blurX
			 	6 , //blurY
			 	2 , //Strength
			 	6 // quality
			)
		];

		draw();
	}

	public function draw(): Void {
		var g:Graphics = this.graphics;

		//g.clear();

		var b:Matrix = new Matrix();
		b.createGradientBox(btnSize.width, btnSize.height);

		g.lineStyle(1.5, 0x000000,0.7);
		g.beginGradientFill(
			GradientType.LINEAR , 
			[gradientBegin, gradientEnd], 
			[1, 1], 
			[1, 255],
			b
		);

		g.drawRoundRect(btnSize.x + 6, btnSize.y + 6, btnSize.width - 12, btnSize.height - 12, 16, 16);
		g.endFill();

		var bmpData:BitmapData = new BitmapData(
			Std.int(btnSize.width + 6), 
			Std.int(btnSize.height + 6), 
			true , 
			0x000000
		);
		
		bmpData.draw(this);
		bmpData.draw(bmText);

		bitmap = new Bitmap(bmpData);
	}
}