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

package  org.decatime.ui.canvas.remote;

#if !flash
import sys.net.Host;
import sys.net.Socket;
import haxe.io.Bytes;
import flash.events.Event;
import flash.utils.Timer;
import flash.events.TimerEvent;
import org.decatime.Facade;
import  org.decatime.ui.canvas.remote.CmdParser;
import haxe.io.Bytes;
#if cpp
import cpp.zip.Uncompress;
#end
#if neko
import neko.zip.Uncompress;
#end

class Server {
	public static var isMsgCompressed:Bool = true;

	private static var TM_DELAY:Int = 50;
	private static var NB_CNX:Int = 10;

	private static var socket:Socket;
	private static var hostName:String;
	private static var hostPort:Int;
	private static var tm:Timer;
	private static var cmdParser:CmdParser;


	public static function start(cv:RemoteDrawingSurface, hostAddr:String, port:Int) {
		cmdParser = new CmdParser(cv);
		hostName = hostAddr;
		hostPort = port;
		
		tm = new Timer(50);
		tm.addEventListener(TimerEvent.TIMER, onTmEvent);

		getConnected();
	}

	private static function getConnected(): Void {
		socket = new Socket();
		socket.setBlocking(false);
		socket.bind(new Host(hostName), hostPort);
		socket.listen(NB_CNX);
		tm.start();
	}

	private static function onTmEvent(e:TimerEvent): Void {
		try {
			var sk:Socket = socket.accept();
			if (sk != null) {
				if (isMsgCompressed) {
					var cpBytes:Bytes = sk.input.readAll();
					var msg:Bytes = Uncompress.run(cpBytes);
					cmdParser.parse(msg.toString());
				} else {
					//trace ("the packet is uncompressed");
					var msg:String = sk.input.readLine();
					cmdParser.parse(msg);
				}
				
			}
		} catch (e:Dynamic) {
			// //trace (e);
			// since we are in a non blocking socket...
		}
	}
}
#end