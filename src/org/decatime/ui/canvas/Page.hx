package org.decatime.ui.canvas;
import org.decatime.Facade;
import org.decatime.ui.canvas.remote.CmdParser;

class Page {
	private static var NAMESPACE:String = " org.decatime.ui.canvas.Page: ";
	
	private var pageContent:Array<String>;
	private var prevContent:Array<String>;
	private var pageIndex:Int;
	private var lastStyCmd:String;
	private var lastEffCmd:String;

	private var parent:Document;

	public function new(parent:Document, idx:Int) {
		this.parent = parent;
		pageIndex = idx;
		init();
	}

	public function init(): Void {
		pageContent = new Array<String>();
		prevContent = new Array<String>();
		if (pageIndex > 0) {
			var previousPage:Page = parent.getPage(pageIndex - 1);
			var styCmd:String = previousPage.getLastStyCmd();
			if (styCmd != null) {
				pageContent.push(styCmd + "\n");
				Facade.doLog("the default style for this page number " + pageIndex + " has been setted", this);
			}
			var effCmd:String = previousPage.getLastEffCmd();
			if (effCmd != null) {
				pageContent.push(effCmd + "\n");
				Facade.doLog("the default effect for this page number " + pageIndex + " has been setted", this);
			}

		} else { 
			if (lastStyCmd != null) {
				pageContent.push(lastStyCmd + "\n");
				Facade.doLog("this is the first page. the last style of this page has been setted", this);
			}
			if (lastEffCmd != null) {
				pageContent.push(lastEffCmd + "\n");
				Facade.doLog("this is the first page. the last effect of this page has been setted", this);
			}
		} 
	}

	public function getLastStyCmd(): String {
		return lastStyCmd;
	}

	public function getLastEffCmd(): String {
		return lastEffCmd;
	}

	public function getIndex(): Int {
		return pageIndex;
	}

	public function add(line:String): Void {
		line = StringTools.trim(line);
		var cmdValue:String = line.substr(0, 3);
		Facade.doLog('command value is ' + cmdValue, this);

		// clear command ?
		if (line == CmdParser.CMD_CLEAR + CmdParser.CMD_SUFFIX) {
			Facade.doLog('the page has been cleared', this);
			init();
		}

		// undo command ?
		if (line == CmdParser.CMD_UNDO + CmdParser.CMD_SUFFIX) {
			Facade.doLog('undo command received removing the last command and butting it into the array of undo elements', this);
			prevContent.push(pageContent.pop());
			return; // job done
		}

		// redo command ?
		if (line == CmdParser.CMD_REDO + CmdParser.CMD_SUFFIX) {
			Facade.doLog('redo command received. adding the last command from undo elements to the page content', this);
			pageContent.push(prevContent.pop());
			return; // job done
		}

		if (cmdValue == CmdParser.CMD_STY) {
			Facade.doLog('style command detected. Checking if it is the same', this);
			var pCommand:String = pageContent[pageContent.length - 1];
			if (pCommand == line + "\n") {
				Facade.doLog('same style command do not save...', this);
				return; // job done
			} else {
				Facade.doLog('this line: ' + line, this);
				Facade.doLog('does not match: ' + pCommand, this);
				lastStyCmd = line;
			}
		}

		if (cmdValue == CmdParser.CMD_EFF) {
			Facade.doLog('Effect command detected. Checking if it is the same', this);
			var pCommand:String = pageContent[pageContent.length - 1];
			if (pCommand == line + "\n") {
				Facade.doLog('same effect command do not save...', this);
				return; // job done
			} else {
				Facade.doLog('this line: ' + line, this);
				Facade.doLog('does not match: ' + pCommand, this);
				lastEffCmd = line;
			}
		}

		pageContent.push(line + "\n");
	}

	public function getContent(): String {
		var buffer:StringBuf = new StringBuf();
		var ln:String = "";
		for (ln in pageContent) {
			buffer.add(ln);
		}
		return buffer.toString();
	}
}