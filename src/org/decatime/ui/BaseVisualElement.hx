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

import flash.display.Sprite;
import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

/**	
*	<p>Base class for all DisplayObject that are based on a Sprite and that
*	needs to be integrated.
*/
class BaseVisualElement extends Sprite implements IVisualElement {
	// TODO : rename to something like BaseSpriteElement
	
	private var sizeInfo:Rectangle;
	public var isContainer:Bool;
	private var elBackColor:Int;
	/**
	* Default constructor.
	* @param name The name for this BaseShapeElement instance	
	*/
	public function new(name:String) {
		super();
		this.name = name;
		// By default this instance act has a button(respond to mouse events)
		this.buttonMode = true;
		// When the refresh method is called if isContainer property
		// is setted to true then this component is resized to fit the
		// Rectangle info passed to the refresh method. This is due to the
		// fact that the with and height property of a Sprite cannot
		// be set directly (it can in fact but will change the aspect ratio).
		this.isContainer = true;

		this.elBackColor = 0x000000;
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
			throw ("provided Rectangle instance value is null");
		}
		this.sizeInfo = r;

		// if we are a container we must be sized by the rect content
		// to do so we need to draw something since setting the width and height
		// will not work has expected.
		if (isContainer) {
			graphics.clear();
			graphics.beginFill(elBackColor, 1);
			graphics.drawRect(r.x, r.y, r.width, r.height);
		} else {
			// i am just a visual component. my size is dynamic
			x = r.x;
			y = r.y;
		}
		
	}
	
	/**
	* IVisualElement implementation. returns the Graphics instance of this
	* Shape.
	*
	* @return Graphics a Graphics instance.
	*/
	public function getDrawingSurface(): Graphics {
		return graphics;
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
	* Toggle the visibility of this Shape depending on the <code>value</code> 
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