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

import flash.display.Graphics;
import flash.geom.Rectangle;

/**	
*	<p>This interface type is used to interact with an object that holds or
*	that is in a display list.
*/
interface IVisualElement {
	/**
	* The refresh function will be call so that the IVisualElement instance
	* update its content with the size constraint <code>Rectangle</code>
	* passed has an argument to the method.
	*/
	function refresh(r:Rectangle): Void;
	
	/**
	* Ask the instance to return a Graphics instance object to draw on.
	*/
	function getDrawingSurface():Graphics;
	
	/**
	* Returns the size that was setted by the last call to refresh method
	*/
	function getInitialSize():Rectangle;
	
	/**
	* Return a String ID for this IVisualElement instance
	*/
	function getId():String;
	
	/**
	* used to toggle the visibility of the IVisualElement
	*/
	function setVisible(value:Bool):Void;
}