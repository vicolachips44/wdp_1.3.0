package org.decatime.utils;

#if !flash
import sys.io.File;
import sys.io.FileOutput;

class Logger {
	private var filePath:String;
	private var fhandle:FileOutput;

	public function new(filePath:String) {
		this.filePath = filePath;
		fhandle = File.write(filePath, false);
	}

	public function log(msg:String, sender:Dynamic): Void {
		var senderName:String = Type.getClassName(Type.getClass(sender));
		fhandle.writeString(senderName + ">>" + msg + "\n");
		fhandle.flush();
	}
}
#end