package org.decatime.ui;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldType;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;
import flash.display.Graphics;
import flash.errors.Error;
import flash.geom.Rectangle;
import flash.geom.Point;

class Label extends TextField implements IVisualElement {
	private var sizeInfo:Rectangle;
	private var label:String;
	private var lblColor:Int;
	private var fontName:String;
	private var fontSize:Int;
	private var margins:Point;
	private var formatAlign:String;
	private var sizeFill:Bool;

	public function new(name:String, label:String, ?lblColor:Int = 0xffffff) {
		super();
		this.name = name;
		this.label = label;
		this.lblColor = lblColor;
		this.wordWrap = true;
		fontName = Facade.getInstance().getDefaultFont().fontName;
		fontSize = Facade.getInstance().getDefaultFontSize();
		this.margins = new Point(0, 0);
		formatAlign = flash.text.TextFormatAlign.CENTER;
		sizeFill = false;
	}

	public function setSizeFill(value:Bool): Void {
		this.sizeFill = value;
	}

	public function setMargins(p:Point): Void {
		this.margins = p;
	}

	public function setLabel(value:String): Void {
		this.text = value;
	}

	public function setFontSize(value:Int): Void {
		fontSize = value;
	}

	public function setFontName(value:String): Void {
		fontName = value;
	}

	public function setBackgroundColor(clValue:Int): Void {
		this.background = true;
		this.backgroundColor = clValue;
	}

	public function setDrawBorder(clValue:Int): Void {
		this.border = true;
		this.borderColor = clValue;
	}

	public function setAlign(value:String): Void {
		formatAlign = value;
	}

	public function setWidth(value:Float): Void {
		#if flash
		// TODO find the good way
		#else
		this.width = value;
		this.textWidth = value;
		#end
	}

	public function setHeight(value:Float): Void {
		this.height = value;
		//init();
	}

	private function init(): Void {
		this.selectable = false;
		this.autoSize = TextFieldAutoSize.NONE; //align;

		this.mouseEnabled = false;
		this.text = label;

		// new TextFormat( 
		// 	?font : String , 
		// 	?size : Null<Float> , 
		// 	?color : Null<Int> , 
		// 	?bold : Null<Bool> , 
		// 	?italic : Null<Bool> , 
		// 	?underline : Null<Bool> , 
		// 	?url : String , 
		// 	?target : String , 
		// 	?align : nme.text.TextFormatAlign , 
		// 	?leftMargin : Null<Float> , 
		// 	?rightMargin : Null<Float> , 
		// 	?indent : Null<Float> , 
		// 	?leading : Null<Float> 
		// );
		var lformat:TextFormat = new TextFormat(
			fontName, 
			fontSize, 
			lblColor
		);
		lformat.align = formatAlign;
		this.embedFonts = true;
		this.defaultTextFormat = lformat;
		this.setTextFormat(lformat);
	}

	/**
	* IVisualElement implementation. will make the position X and Y match
	* the provided Rectangle instance x and y.
	*
	* @see org.decatime.display.ui.IVisualElement
	*
	* @throws nme.error.Error if the provided Rectangle argument is null
	*/
	public function refresh(r:Rectangle): Void {
		if (r == null) {
			throw new Error("provided Rectangle instance value is null");
		}
		this.sizeInfo = r;
		
		x = r.x + margins.x;
		y = r.y + margins.y;

		if (sizeFill) {
			this.width = r.width;
			this.height = r.height;
		}
		init();
	}

	/**
	* IVisualElement implementation. returns the Graphics instance of this
	* object.
	*
	* @return Graphics a Graphics instance.
	*/
	public function getDrawingSurface(): Graphics {
		return null;
	}

	/**
	* IVisualElement implementation. returns the sizeInfo property that was
	* setted in the refresh method call.
	*
	* @return nme.geom.Rectangle containing the dimension.
	*/
	public function getInitialSize(): Rectangle {
		return sizeInfo;
	}

	/**
	* IVisualElement implementaion. return the name that was defined when
	* calling the constructor of this instance.
	*
	* @return String the name.
	*/
	public function getId(): String {
		return name;
	}

	/**
	* Toggle the visibility of this object depending on the <code>value</code> 
	* param
	*
	* @param value a Boolean value to toggle the visibility
	*
	* @return Void
	*/
	public function setVisible(value:Bool): Void {
		this.visible = value;
	}
}