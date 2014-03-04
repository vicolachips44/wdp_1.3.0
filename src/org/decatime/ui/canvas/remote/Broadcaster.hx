package  org.decatime.ui.canvas.remote;
#if !flash
import sys.net.Socket;
import sys.net.Host;
import org.decatime.Facade;
import  org.decatime.ui.canvas.DrawingSurface;
import haxe.io.Bytes;

#if cpp
import cpp.zip.Compress;
import cpp.vm.Thread;
#end
#if neko
import neko.zip.Compress;
import neko.vm.Thread;
#end

import flash.utils.Timer;
import flash.events.TimerEvent;

class Broadcaster {
	private var host:Host;
	private var isConnected:Bool;
	private var port:Int;
	private static var currMsg:String;
	private var threadSend:Thread;
	private var tmCheckThread:Timer;
	private var bIsOnLine:Bool;
	private var bCompress:Bool;

	public function new(remoteHost:String, port:Int) {
		//trace ("creating remote broadcaster at " + remoteHost);
		host = new Host(remoteHost);
		this.port = port;
		bCompress = true;
		tmCheckThread = new Timer(4000);
		tmCheckThread.addEventListener(TimerEvent.TIMER, onTmElapsed);
	}

	public function getRemoteHostIp(): String {
		return host.toString();
	}

	private function onTmElapsed(e:TimerEvent): Void {
		var alive:String = Thread.readMessage(true);
		if (alive == "ok") { return; }
		Facade.notifyAndDisBroadcast(alive, this);
		tmCheckThread.stop();
	}

	public function send(msg:String): Void {
		if (threadSend == null) {
			threadSend = Thread.create(sendCallback);
			tmCheckThread.start();
		}
		threadSend.sendMessage(Thread.current());

		if (bCompress) {
			var cpMsg:Bytes = Compress.run(Bytes.ofString(msg), 9 );
			threadSend.sendMessage(cpMsg.toString());
		} else {
			threadSend.sendMessage(msg);
		}
		
		threadSend.sendMessage(host);
		threadSend.sendMessage(port);
	}

	private function sendCallback(): Void {
		while (true) {
			var main:Thread = Thread.readMessage(true);
			var msg:String = Thread.readMessage(true);
			var h:Host = Thread.readMessage(true);
			var p:Int = Thread.readMessage(true);

			try {
				var socket:Socket = new Socket();
				//trace ("connecting to " + h.toString());
				socket.connect(h, p);
				socket.setTimeout(500);
				socket.write(msg);
				socket.shutdown(true, true);
				socket.close();
				main.sendMessage("ok");
			} catch (e:Dynamic) {
				var msg:String = "host with ip " + host.toString() + " is unreachable\n the broadcaster will be disabled!";
				main.sendMessage(msg);
			}
		}
	}

	public function dispose(): Void {
		// Clean up
		threadSend = null;
	}
}
#end