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
 
package org.decatime.events;

/*
* Small helper and adapter class to apply the IObservable pattern.
*/
class EventManager implements IObservable {

	private var observable:IObservable;
	private var observers:Array<IObserver>;
	
	/**
	* Default constructor that needs the IObservable instance to manage.
	*
	* @param observable IObservable instance to manage.
	*/
	public function new (observable:IObservable) {
		this.observable = observable;
		observers = new Array<IObserver>();
	}

	/**
	* method to add a IObserver instance to the list of observers.
	*
	* @param observer IObserver instance
	*/
	public function addListener(observer:IObserver): Void {
		observers.push(observer);
	}

	/**
	* method to remove an IObserver instance from the list of observers.
	*
	* @param observer IObserver instance
	*/
	public function removeListener(observer:IObserver): Void {
		observers.remove(observer);
	}

	/**
	* method that will notify all observers about the given event name.
	*
	* @param name the event Name
	* @param data the Dynamic content to broadcast with the event
	*/
	public function notify(name:String, data:Dynamic): Void {
		var obs:IObserver;

		for (obs in observers) {
			obs.handleEvent( name , observable , data );
		}
	}
}