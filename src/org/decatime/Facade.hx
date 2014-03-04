package org.decatime;

import openfl.Assets;

import flash.Lib;
import flash.text.Font;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.geom.Rectangle;

import org.decatime.ui.BaseVisualElement;
import org.decatime.events.EventManager;
import org.decatime.ui.Window;
import org.decatime.ui.canvas.remote.Broadcaster;
import org.decatime.ui.canvas.DocManager;
import org.decatime.ui.MessageDlg;
import org.decatime.events.IObserver;
import org.decatime.events.IObservable;
import org.decatime.ui.canvas.DrawingSurface;
import org.decatime.ui.canvas.remote.RemoteDrawingSurface;
import org.decatime.ui.canvas.effects.EffectManager;
import org.decatime.ui.canvas.remote.CmdParser;

import org.decatime.utils.Logger;

class Facade extends EventManager implements IObserver {
	public static var EV_INIT:String = "org.decatime.Facade.EV_INIT";
	public static var EV_READY:String = "org.decatime.Facade.EV_READY";
	public static var EV_RESIZE:String = "org.decatime.Facade.EV_RESIZE";
	public static var EV_DOC_MANAGER_LOADED:String = "org.decatime.Facade.EV_DOC_MANAGER_LOADED";

	private static var instance:Facade;

	private var root:BaseVisualElement;
	private var tmResize:Timer;
	private var defaultFont:Font;
	private var defaultFontSize:Int;
	private var stageRect:Rectangle;
	private var windowList:Array<Window>;
	private var activeWindow:Window;
	private var visibleWindows:Array<Window>;
	private var docManager:DocManager;
	private var effManager:EffectManager;
	private var canvas:DrawingSurface;
	private var logger:Logger;

	#if !flash
	private var broadcasters:Array<Broadcaster>;
	private var bdcEnable:Bool;
	#end

	public static function doLog(msg:String, sender:Dynamic): Void {
		trace (msg);
		// #if logdebug
		// instance.logger.log(msg, sender);
		// #end
	}

	public static function broadcastEnable(value:Bool): Void {
		instance.bdcEnable = value;
	}


	#if !flash
	public static function notifyAndDisBroadcast(msg:String, b:Broadcaster): Void {
		instance.removeBroadcaster(b);
		var ip:String = b.getRemoteHostIp();
		trace ("the broadcasting has been disabled...");
		b.dispose();
		b = null;
		// Facade.doLog("the broadcaster with ip " + ip + " has been removed");
	}
	#end

	private function new() {
		super(this);
		#if logdebug
		logger = new Logger('/media/victor/bigfoot/shareFolder/dev/haxe/wdp_1.2.0/wdp1.2.0.log');
		logger.log('In Facade instance private constructor - BEGIN', this);
		#end

		Lib.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.stage.align = StageAlign.TOP_LEFT;

		Lib.stage.stageFocusRect = false;
		
		this.windowList = new Array<Window>();
		visibleWindows = new Array<Window>();
		#if ! flash
		broadcasters = new Array<Broadcaster>();
		bdcEnable = true;
		#if logdebug
		logger.log('Broadcasters array has been initialized', this);

		#end
		#end
	}

	public static function getInstance(): Facade {
		if (instance == null) {
			instance = new Facade();
		}
		return instance;
	}

	public function doBroadCast(msg:String): Void {
		if (Facade.getInstance().getCanvas() == null) { return; }
		if (msg.length == 0) { return; }

		if (instance.docManager == null) { 
			throw "Doc manager has not been initialized";
		}
		if (instance.bdcEnable == false) { return; }
		
		doLog("broadcast: " + msg, Facade.instance);
		this.docManager.getActiveDocument().getActivePage().add(msg);

		if (this.broadcasters != null && this.broadcasters.length == 1) {
			this.broadcasters[0].send(msg);
		}
		
		// if (msg.substr(0, 3) == 'eff') {
		// 	var parser:org.decatime.ui.canvas.remote.CmdParser = new CmdParser(instance.canvas);
		// 	parser.parse(msg);
		// }
	}

	public function addBroadcaster(value:Broadcaster): Void {
		broadcasters.push(value);
	}

	public function removeBroadcaster(value:Broadcaster): Void {
		broadcasters.remove(value);
	}

	public function setCanvas(value:DrawingSurface): Void {
		this.canvas = value;
		this.docManager = new DocManager(canvas); 
		this.effManager = new EffectManager(canvas);
		Facade.doLog('Canvas instance has been setted and doc manager and effect manager are now created', this);

	}

	public function getCanvas(): DrawingSurface {
		return this.canvas;
	}

	public function getStageRect(): Rectangle {
		return this.stageRect;
	}

	public function getWindowList(): Array<Window> {
		return windowList;
	}

	public function getWindowByName(name:String): Window {
		for(i in 0...windowList.length) {
			if (windowList[i].getId() == name) {
				return windowList[i];
			}
		}
		return null;
	}

	public function showPopup(name:String, ?args:Dynamic = null) {
		var modal:Bool = true;
		var w:Window = getWindowByName(name);

		if (w == null) {
			throw ("Error while trying to get a popup instance with name : " + name);
		}

		if (w.isModal()) {
			closePopup();
			activeWindow = w;
			activeWindow.show(args);
		} else {
			visibleWindows.push(w);
			visibleWindows[visibleWindows.length - 1].show(args);
			modal = false;
		}
	}

	public function showMessage(msgContent:String, ?msgType:String = "messageTypeInfo"): MessageDlg {
		var msgDlg:MessageDlg = new MessageDlg('messageDlg', msgType);
		msgDlg.setMessage(msgContent);
		msgDlg.show(null);
		return msgDlg;
	}

	public function closeAllPopup(): Void {
		var w:Window = null;
		for (w in visibleWindows) { w.close(); }
	}

	public function closePopup() {
		if (activeWindow != null) {
			activeWindow.close();
		}
		activeWindow == null;
	}

	public function getEffectManager(): EffectManager {
		return effManager;
	}

	public function getDocManager(): DocManager {
		return docManager;
	}
	public function setDocManager(manager:DocManager): Void {
		docManager = manager;
	}

	public function getPathSeparator(): String {
        return Sys.systemName() == "Windows" ? "\\" : "/";
    }

	public function getRoot(): BaseVisualElement {
		return root;
	}

	public function registerWindow(w:Window) {
		this.windowList.push(w);
	}

	public function setDefaultFontSize(value:Int): Void {
		defaultFontSize = value;
	}

	public function getDefaultFontSize(): Int {
		return defaultFontSize;
	}

	public function setDefaultFont(resource:String): Void {
		//trace ("loading font resources : " + resource);
		defaultFont = Assets.getFont(resource);
	}

	public function getDefaultFont(): Font {
		return defaultFont;
	}

	public function run(root:BaseVisualElement, ?bFullScreen:Bool = false): Void {
		if (bFullScreen) {
			Lib.stage.displayState = StageDisplayState.FULL_SCREEN;
			flash.ui.Mouse.hide();
		}
		this.root = root;
		Facade.doLog('The root object has been setted', this);
		root.addEventListener(Event.ADDED_TO_STAGE, onRootAddedToStage);
		//trace ("adding the root has a child of the stage...");
		Lib.stage.addChild(root);
		Facade.doLog('The root object is now on stage', this);
	}

	public function onRootAddedToStage(e:Event): Void {
		root.removeEventListener(Event.ADDED_TO_STAGE, onRootAddedToStage);
		Facade.doLog('The root object has been added to the stage. Calling initialize', this);
		initialize();
		Facade.doLog('Initialize of Facade done', this);
	}

	private function initialize() {
		tmResize = new Timer(1);
		tmResize.addEventListener(TimerEvent.TIMER, onTmResizeCycle);
		notify(EV_INIT, root);
		Facade.doLog('Calling resize for the first time', this);
		onResize(null);
		Facade.doLog('Notifying ready state of the Facade...', this);
		notify(EV_READY, root);
		Facade.doLog('Ready state event raised done', this);
		Facade.doLog('Adding listener for the stage resize event...', this);
		Lib.stage.addEventListener( Event.RESIZE, onResize);
		Facade.doLog('Listener for the stage resize event has been setted', this);
	}

	private function onResize(e:Event): Void {
		//trace ("entering resize event...");
		if (tmResize.running) { return; }
		tmResize.start();
	}

	private function onTmResizeCycle(e:TimerEvent) {
		tmResize.stop();
		//trace ("resize event has occured");
		stageRect = new Rectangle(0, 0, Lib.stage.stageWidth, Lib.stage.stageHeight);
		Facade.doLog('Thet stageRect property has changed: ' + stageRect.x + "," + stageRect.y + "," + stageRect.width + "," + stageRect.height, this);
		root.refresh(stageRect);
		notify(EV_RESIZE, root);
	}

	/**
	* Method called by a IObservable object if this IObservec object has
	* register its instance.
	*
	* @param name the String name of the event
	* @param sender the IObservable instance that is broadcasting the message
	* @param data Dynamic that can be of any type
	*
	* @return Void
	*/
	public function handleEvent(name:String, sender:IObservable, data:Dynamic): Void {
		
	}

	/**
	* Represent a collection of id events that the observer wan'ts to listen to
	*
	*/
	public function getEventCollection(): Array<String> {
		return [];
	}
}