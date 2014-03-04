package org.decatime.ui.canvas;

import org.decatime.Facade;
import  org.decatime.events.IObservable;
import  org.decatime.events.IObserver;
import  org.decatime.events.EventManager;
import  org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import  org.decatime.ui.canvas.DrawingSurface;
import  org.decatime.ui.canvas.remote.CmdParser;
import haxe.io.Bytes;


class DocManager implements  IObservable implements IObserver {
	public static var FILE_EXT:String = "wdp1";
	public static var EVT_NEW_PAGE_ADDED:String = NAMESPACE + "EVT_NEW_PAGE_ADDED";
	public static var EVT_PAGE_NAV:String = NAMESPACE + "EVT_PAGE_NAV";
	public static var EVT_NEW_DOCUMENT_LOADED:String = NAMESPACE + "EVT_NEW_DOCUMENT_LOADED";
	public static var EVT_DOC_SAVED:String = NAMESPACE + "EVT_DOC_SAVED";

	private static var NAMESPACE:String = " org.decatime.ui.canvas.DocManager: ";

	private var surface:DrawingSurface;
	private var evManager:EventManager;
	private var activeDocument:Document;

	public function new(surface:DrawingSurface) {
		createDefaultDocument();
		evManager = new EventManager(this);
		this.surface = surface;
	}

	#if !flash
	public function loadFile(fullPath:String): Void {
		activeDocument.load(fullPath);
		loadCurrPage();
		evManager.notify(EVT_NEW_DOCUMENT_LOADED, fullPath);
	}

	public function saveActiveDocument(documentFullPath:String) {
		activeDocument.save(documentFullPath);
		evManager.notify(EVT_DOC_SAVED, documentFullPath);
	}	
	#end
	public function getActiveDocument(): Document {
		return activeDocument;
	}

	public function newPage(): Void {
		var newIndex:Int = activeDocument.addPage();

		activeDocument.setActivePage(newIndex);
		if (surface == null) {
			throw "surface object is null";
		}
		surface.setMode(RemoteDrawingSurface.MODE_LOADING);
		surface.clear();	
		surface.setMode(RemoteDrawingSurface.MODE_NORMAL);

		evManager.notify(EVT_NEW_PAGE_ADDED, activeDocument.getActivePage());
	}

	public function deletePage(pageNum:Int): Void {
		activeDocument.deletePage(pageNum - 1);
		movePrevious();
	}

	public function getPageCount(): Int {
		return activeDocument.getPageCount();
	}

	public function getCurrPageNum(): Int {
		return activeDocument.getCurrPageNum();
	}

	public function canGoPrevious(): Bool {
		return activeDocument.getCurrPageNum() > 1;
	}

	public function movePrevious(): Void {
		var index:Int = activeDocument.getCurrPageNum() - 1;
		activeDocument.setActivePage(index -1);
		loadCurrPage();
		evManager.notify(EVT_PAGE_NAV, activeDocument.getActivePage());
	}

	public function canGoNext(): Bool {
		return activeDocument.getPageCount() > activeDocument.getCurrPageNum();
	}

	public function moveNext(): Void {
		var index:Int = activeDocument.getCurrPageNum();
		activeDocument.setActivePage(index);
		loadCurrPage();
		evManager.notify(EVT_PAGE_NAV, activeDocument.getActivePage());
	}

	private function createDefaultDocument(): Void {
		activeDocument = new Document('new1_' + Date.now().toString());
	}

	public function loadCurrPage(): Void {
		Facade.doLog('loading the current page : ' + activeDocument.getActivePage().getIndex(), this);

		surface.setMode(RemoteDrawingSurface.MODE_LOADING);
		surface.clear();

		var parser:CmdParser = new CmdParser(surface);
		var cmds:Array<String> = activeDocument.getActivePage().getContent().split("\n");
		var cmd:String = "";
		Facade.doLog('begin of document parse', this);
		for (cmd in cmds) {
			parser.parse(cmd);
		}
		Facade.doLog('end of document parse', this);
		surface.setMode(RemoteDrawingSurface.MODE_NORMAL);
		Facade.doLog('loadCurrPage method has ended...', this);
	}

	public function handleEvent(name:String, sender:IObservable, data:Dynamic) {
		switch (name) {
			case DrawingSurface.EVT_SURFACE_CLEARED:
				activeDocument.getActivePage().init();
		}
	}

	public function getEventCollection(): Array<String> {
		return [
			DrawingSurface.EVT_SURFACE_CLEARED
		];
	}

	// IObservable implementation
	public function addListener(observer:IObserver): Void {
		evManager.addListener(observer);
	}
	public function removeListener(observer:IObserver): Void {
		evManager.removeListener(observer);
	}

	public function notify(name:String, data:Dynamic): Void {
		evManager.notify(name, data);
	}
	// IObservable implementation END
}