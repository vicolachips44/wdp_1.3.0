package org.decatime.ui;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldType;
import flash.text.TextFieldAutoSize;
import flash.display.Graphics;
import flash.errors.Error;
import flash.geom.Rectangle;
import flash.geom.Point;

class TextBox extends TextField implements IVisualElement {
	private var sizeInfo:Rectangle;
	private var fontName:String;
	private var fontSize:Int;
	private var txtColor:Int;
	private var margins:Point;

	public function new(name:String, text:String, ?txtColor:Int = 0x000000) {
		super();
		this.name = name;
		this.type = TextFieldType.INPUT;
		this.mouseEnabled = true;
		this.selectable = true;
		
		this.border = true;
		this.borderColor = 0x000000;
		this.autoSize = TextFieldAutoSize.NONE;

		this.txtColor = txtColor;
		this.margins = new Point(0, 0);
		this.fontName = Facade.getInstance().getDefaultFont().fontName;
		this.fontSize = Facade.getInstance().getDefaultFontSize();

		init(text);
	}

	public function setMargins(p:Point): Void {
		this.margins = p;
	}

	private function init(text:String): Void {
		this.text = text;
		var format:TextFormat = new TextFormat(
			fontName, 
			fontSize, 
			txtColor
		);

		this.embedFonts = true;
		this.defaultTextFormat = format;
		this.setTextFormat(format);
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
		this.width = r.width;
		this.height = this.textHeight + 6;
		
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