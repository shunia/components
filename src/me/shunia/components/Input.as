package me.shunia.components
{

	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;

	public class Input extends Label
	{
		
		protected var _placeHolder:String = "";
		protected var _showingPlaceHolder:Boolean = false;
		protected var _focused:Boolean = false;
		protected var _onEnter:Function = null;
		protected var _onEnterClear:Boolean = true;
		
		public function Input()
		{
			super();
			mouseEnabled = true;
			selectable = true;
			type = TextFieldType.INPUT;
			autoSize = TextFieldAutoSize.NONE;
			
			addEventListener(FocusEvent.FOCUS_IN, onFocused);
			addEventListener(FocusEvent.FOCUS_OUT, onFocused);
		}
		
		public function set onEnter(value:Function):void {
			_onEnter = value;
			if (_onEnter != null) 
				startEnter();
			else 
				stopEnter();
		}
		
		public function set onEnterClear(value:Boolean):void {
			_onEnterClear = value;
		}
		
		protected function startEnter():void {
			addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		protected function onKeyUp(e:KeyboardEvent):void {
			if (!_showingPlaceHolder && text.length && _onEnter != null) {
				_onEnter(text);
				if (_onEnterClear) 
					text = "";
			}
		}
		
		protected function stopEnter():void {
			removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		public function set placeHolder(value:String):void {
			_placeHolder = value;
			if (_placeHolder == null) 
				stopPlaceHolder();
			else 
				startPlaceHolder();
		}
		
		public function get placeHolder():String {
			return _placeHolder;
		}
		
		protected function startPlaceHolder():void {
			if (text.length == 0) _showingPlaceHolder = true;
			if (text.length == 0 && !_focused) text = _placeHolder;
			
			addEventListener(TextEvent.TEXT_INPUT, onInput);
		}
		
		protected function onInput(e:TextEvent):void {
			if (text.length > 0) _showingPlaceHolder = false;
		}
		
		protected function onFocused(e:FocusEvent):void {
			switch (e.type) {
				case FocusEvent.FOCUS_IN : 
					_focused = true;
					if (_showingPlaceHolder) text = "";
					break;
				case FocusEvent.FOCUS_OUT : 
					_focused = false;
					if (text.length == 0) _showingPlaceHolder = true;
					else _showingPlaceHolder = false;
					if (_showingPlaceHolder) text = _placeHolder;
					break;
			}
		}
		
		protected function stopPlaceHolder():void {
			_showingPlaceHolder = false;
			
			removeEventListener(FocusEvent.FOCUS_IN, onFocused);
			removeEventListener(FocusEvent.FOCUS_OUT, onFocused);
			removeEventListener(TextEvent.TEXT_INPUT, onInput);
		}
		
	}
}