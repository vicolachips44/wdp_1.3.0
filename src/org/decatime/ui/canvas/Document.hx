package org.decatime.ui.canvas;

#if cpp
import cpp.zip.Uncompress;
import cpp.zip.Compress;
#end
#if neko
import neko.zip.Uncompress;
import neko.zip.Compress;
#end
import haxe.io.Bytes;

class Document {
	private static var PAGE_BREAK_TOKEN:String = "[[PAGE_BREAK]]\n";
	private var name:String;
	private var pages:Array<Page>;
	private var activeIndex:Int;
	private var fullPath:String;

	public function new(name:String) {
		this.name = name;
		pages = new Array<Page>();
		pages.push(new Page(this, 0));
		activeIndex = 0;
		fullPath = "";
	}


	#if (cpp || neko)

	public function getPath(): String {
		return fullPath;
	}
	
	public function save(documentFullPath:String): Void {
		var handle:sys.io.FileOutput = sys.io.File.write(documentFullPath);
		var p:Page = null;
		var fullStream:String = "";
		for (p in pages) {
			fullStream += PAGE_BREAK_TOKEN;
			fullStream += p.getContent();
		}
		// var cpMsg:Bytes = Compress.run(Bytes.ofString(fullStream), 9 );
		// handle.write(cpMsg);
		handle.writeString(fullStream);
		handle.close();
		fullPath = documentFullPath;
	}

	public function load(documentFullPath:String): Void {
		pages = new Array<Page>();
		var handle:sys.io.FileInput = sys.io.File.read(documentFullPath);
		var newPage:Bool = false;
		var currPage:Page = null;
		var index:Int = 0;
		var cpBytes:Bytes = handle.readAll();
		// var msg:Bytes = Uncompress.run(cpBytes);
		// var lines:Array<String> = msg.toString().split("\n");
		var lines:Array<String> = cpBytes.toString().split("\n");
		for (line in lines) {
			if (line == "[[PAGE_BREAK]]") {
				newPage = true;	
			} else {
				if (newPage) {
					newPage = false;
					setActivePage(addPage());
					currPage = getActivePage();
				}
				if (line.length > 0) {
					currPage.add(line);	
				}
				newPage = false;
			}
		}
		fullPath = documentFullPath;
	}
	#end

	public function getName(): String {
		return name;
	}
	public function setName(value:String): Void {
		name = value;
	}

	public function addPage(): Int {
		pages.push(new Page(this, pages.length));
		return pages.length -1;
	}

	public function getPageCount(): Int {
		return pages.length;
	}	

	public function getCurrPageNum(): Int {
		return activeIndex + 1;
	}

	public function getActivePage(): Page {
		return pages[activeIndex];
	}

	public function setActivePage(index:Int): Void {
		activeIndex = index;
	}

	public function getPage(index:Int): Page {
		return pages[index];
	}

	public function deletePage(index:Int): Void {
		pages.splice(index, 1);
	}
}