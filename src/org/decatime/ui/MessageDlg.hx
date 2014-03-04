package org.decatime.ui;

import flash.geom.Rectangle;
import flash.Lib;
import flash.display.SimpleButton;
import flash.events.MouseEvent;

import org.decatime.Facade;
import org.decatime.layouts.BoxLayout;
import org.decatime.layouts.LayoutContent;
import org.decatime.layouts.DirectionType;
import org.decatime.ui.Label;
import org.decatime.ui.BaseVisualElement;
import org.decatime.ui.ButtonFactory;

import org.decatime.events.IObserver;
import org.decatime.events.IObservable;
import org.decatime.events.EventManager;

class MessageDlg extends Window implements IObservable {

	public static var MESSAGETYPE_INFO:String = "messageTypeInfo";
	public static var MESSAGETYPE_QUESTION:String = "messageTypeQuestion";
	public static var DLG_RESULT:String = "dlgResult";

	public static var DLG_RESULT_NO:String = "no";
	public static var DLG_RESULT_YES:String = "yes";

	private static var NAMESPACE:String = "org.decatime.ui.MessageDlg: ";

	private var messsage:String;
	private var msgType:String;
	private var lbl:Label;
	private var evManager:EventManager;
	private var btnNo:BaseVisualElement;
	private var btnYes:BaseVisualElement;
	private var dlgResult:String;

	public function new(n:String, msgType:String) {
		var title:String = "";
		
		if (msgType == MESSAGETYPE_INFO) {
			title = "Info";
		} else if (msgType == MESSAGETYPE_QUESTION) {
			title = "Pending action";
		}
		this.msgType = msgType;

		super(n, title, Facade.getInstance().getRoot());
		position = new Rectangle(0, 0, 340, 220);
		this.evManager = new EventManager(this);
	}

	public function getDialogResult(): String {
		return dlgResult;
	}

	public function setMessage(msg:String) {
		this.messsage = msg;
	}

	public override function isModal(): Bool {
		return true;
	}

	private override function initializeComponent(r:Rectangle): Void {
		// todo construct IHM
		var vbox:BoxLayout = new BoxLayout(clientArea, DirectionType.VERTICAL, 'vbox1');
		lbl = new Label('lblMessage', this.messsage, 0x000000);
		lbl.setWidth(290);
		this.addChild(lbl);
		if (msgType == MESSAGETYPE_INFO) {
			vbox.layoutContents.get(vbox.addLayoutContent(1.0)).setItem(lbl);	
		} else {
			vbox.layoutContents.get(vbox.addLayoutContent(90)).setItem(lbl);
			
			var boxBtns:BoxLayout = new BoxLayout(vbox.layoutContents.get(vbox.addLayoutContent(40)), DirectionType.HORIZONTAL, 'boxBtns');

			btnYes = new BaseVisualElement('btnYesContainer');
			btnYes.isContainer = false;
			
			boxBtns.layoutContents.get(boxBtns.addLayoutContent(150)).setItem(btnYes);
			boxBtns.layoutContents.get(1).drawBorder = false;

			addChild(btnYes);
			btnYes.addEventListener(MouseEvent.CLICK, onBtnYesClick);

			var btn:SimpleButton = ButtonFactory.getButton('Yes');
			btnYes.addChild(btn);

			btnNo = new BaseVisualElement('btnNoContainer');
			btnNo.isContainer = false;
			
			boxBtns.layoutContents.get(boxBtns.addLayoutContent(150)).setItem(btnNo);
			boxBtns.layoutContents.get(2).drawBorder = false;

			addChild(btnNo);
			btnNo.addEventListener(MouseEvent.CLICK, onBtnNoClick);

			var btn:SimpleButton = ButtonFactory.getButton('No');
			btnNo.addChild(btn);
		}
		
	}

	private function onBtnYesClick(e:MouseEvent): Void {
		dlgResult = DLG_RESULT_YES;
		evManager.notify(DLG_RESULT, this);
		this.close();
	}

	private function onBtnNoClick(e:MouseEvent): Void {
		dlgResult = DLG_RESULT_NO;
		evManager.notify(DLG_RESULT, this);
		this.close();
	}

	private override function updateProperties(): Void {
		lbl.setLabel(this.messsage);
	}

	/**
	* method to add a IObserver object to the list of observers.
	*/
	public function addListener(observer:IObserver): Void {
		evManager.addListener(observer);
	}
	/**
	* method to remove an IObserver instance from the list of observers.
	*/
	public function removeListener(observer:IObserver): Void {
		evManager.removeListener(observer);
	}
	/**
	* method to notify listeners about new events.
	*/
	public function notify(name:String, data:Dynamic): Void {
		evManager.notify(name, data);
	}
}