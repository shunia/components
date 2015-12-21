package me.shunia.components
{

	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class Form extends Panel
	{
		
		protected static const SUBMIT_LABEL:String = "提交";
		protected static const CANCEL_LABEL:String = "取消";
		protected static const BG_COLOR:uint = 0xfcfcfc;
		protected static const BG_ALPHA:Number = 0.8;
		protected static const ROUND_CORNOR:int = 6;
		protected static const GAP:int = 10;
		
		protected var _f:FormFields = null;
		protected var _bPanel:Panel = null;
		protected var _btnSubmit:Button = null;
		protected var _btnCancel:Button = null;
		protected var _onSubmit:Function = null;
		protected var _submitLabel:String = null;
		protected var _cancelLabel:String = null;
		protected var _onCancel:Function = null;
		
		public function Form(onSubmit:Function = null, onCancel:Function = null, submitLabel:String = null, cancelLabel:String = null)
		{
			super();
			_onSubmit = onSubmit;
			_onCancel = onCancel;
			_submitLabel = submitLabel || SUBMIT_LABEL;
			_cancelLabel = cancelLabel || CANCEL_LABEL;
			_layout.type = Layout.VERTICAL;
			_layout.hGap = GAP;
			_layout.vGap = GAP;
		}
		
		public function getValue():Object {
			return _f.getValue();
		}
		
		public function addField(k:String, label:String = null, value:String = null, pwd:Boolean = false):FormField {
			if (!_f) {
				_f = new FormFields();
				add(_f);
				createBtns();
			}
			var f:FormField = _f.addField(k, label, value, pwd);
			_layout.updateDisplay();
			return f;
		}
		
		protected function createBtns():void {
			if (!_bPanel) {
				_bPanel = new Panel();
				_bPanel.layout.hGap = 40;
				add(_bPanel);
			}
			if (!_btnSubmit) {
				_btnSubmit = new Button();
				_btnSubmit.label = _submitLabel;
				_btnSubmit.on(_onSubmit);
				_bPanel.add(_btnSubmit);
			}
			if (!_btnCancel) {
				_btnCancel = new Button();
				_btnSubmit.label = _cancelLabel;
				_btnCancel.on(_onCancel);
				_bPanel.add(_btnCancel);
			}
			
			addEventListener(KeyboardEvent.KEY_UP, onKeyboardListening);
		}
		
		protected function onKeyboardListening(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER && _onSubmit) _onSubmit.apply();
		}
		
		override protected function paint():void {
			if (_debug) super.paint();
			else {
				graphics.clear();
				graphics.beginFill(BG_COLOR, BG_ALPHA);
				graphics.drawRoundRect(0, 0, _layout.width + GAP * 2, _layout.height + GAP * 2, ROUND_CORNOR, ROUND_CORNOR);
				graphics.endFill();
			}
		}
		
	}
}

import flash.utils.Dictionary;

import me.shunia.components.Input;
import me.shunia.components.Label;
import me.shunia.components.Layout;
import me.shunia.components.Panel;

class FormFields extends Panel {
	
	protected var _items:Dictionary = null;
	
	public function FormFields() {
		super();
		_items = new Dictionary();
		_layout.type = Layout.VERTICAL;
	}
	
	public function addField(k:String, label:String = null, value:String = null, pwd:Boolean = false):FormField {
		var f:FormField = null;
		if (_items.hasOwnProperty(k) && _items[k]) f = _items[k];
		else {
			f = new FormField(label, value, pwd);
			_items[k] = f;
			add(f);
		}
		return _items[k];
	}
	
	public function getValue():Object {
		var o:Object = {};
		for (var k:String in _items) {
			o[k] = _items[k].getValue();
		}
		return o;
	}
	
}

class FormField extends Panel {
	
	protected var _l:Label = null;
	protected var _i:Input = null;
	
	public function FormField(label:String = null, value:String = null, pwd:Boolean = false) {
		super();
		if (label) {
			_l = new Label();
			_l.text = label;
			add(_l);
		}
		_i = new Input();
		_i.height = 22;
		_i.width = 138;
		_i.border = true;
		_i.displayAsPassword = pwd;
		_i.text = value ? value : "";
		add(_i);
	}
	
	public function getValue():String {
		return _i.text;
	}
	
}