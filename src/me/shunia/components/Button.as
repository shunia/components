package me.shunia.components
{

	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * 由于继承了Panel的布局,简化了按钮的布局需求,同时主要api保留原来的样子.
	 *  
	 * @author qingfenghuang
	 */	
	public class Button extends Panel
	{
		
		/**
		 * 对应StateWrapper 
		 */		
		public static var ALL:int = -1;
		public static var UP:int = 1;
		public static var OVER:int = 2;
		public static var DOWN:int = 3;
		public static var DISABLED:int = 4;
		public static var CLICK:int = 1000;
		public static var OUT:int = 1001;
		
		protected var _enabled:Boolean = true;
		protected var _label:Label = null;
		protected var _labelStr:String = "";
		protected var _labelSize:int = 12;
		protected var _labelColor:uint = 0xFFFFFF;
		protected var _state:StateWrapper = null;
		protected var _onState:int = UP;
		protected var _on:Function = null;
		protected var _onStates:Array = null;
		protected var _selected:Boolean = false;
		
		public function Button()
		{
			super();
			
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			
			layout.type = Layout.NONE;
			layout.align = Layout.ALIGN_CENTER;
			
			_state = new StateWrapper();
			add(_state);
			
			_label = new Label();
			_label.size = _labelSize;
			_label.color = _labelColor;
			_label.mouseEnabled = false;
			
			init();
		}
		
		public function set enabled(value:Boolean):void {
			_enabled = value;
			mouseEnabled = _enabled;
			if (!_enabled) 
				_state.state = StateWrapper.DISABLED;
			else 
				_state.state = _state.prevState;
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set label(value:String):void {
			if (value && _label) {
				_label.text = value;
                if (!contains(_label))
    				add(_label);
                else
                    layout.updateDisplay();
			}
		}
		
		public function set labelColor(value:uint):void {
			_labelColor = value;
			if (_label) _label.color = _labelColor;
		}
		
		public function set labelSize(value:int):void {
			_labelSize = value;
			if (_label) _label.size = _labelSize;
			layout.updateDisplay();
		}
		
		public function set state(value:int):void {
			if (value == OUT) _state.state = StateWrapper.UP;
			else if (value == CLICK) _state.state;
			else _state.state = value;
			_onState = value;
		}
		
		public function get state():int {
			return _onState;
		}
		
		public function set selected(value:Boolean):void {
			_selected = value;
			state = _selected ? DOWN : UP;
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		
		public function setStateAsset(state:int, asset:*):void {
			_state.setAsset(state, asset);
			layout.updateDisplay();
		}
		
		/**
		 * 监听按钮事件的快捷方法.
		 * 可以一次监听多个事件,事件的定义取自NewButton中的静态定义,
		 * 将需要监听的状态放到states数组中,就会对相应的监听进行回调.
		 *  
		 * @param cb 回调方法,最多支持两个参数:state-按钮当前的状态,button-当前按钮的引用
		 * @param states 监听的状态列表,支持一次监听多个
		 */		
		public function on(cb:Function, states:Array = null):void {
			_on = cb;
			_onStates = states ? states : [CLICK];
		}
		
		protected function init():void {
			var onAdded:Function = function (e:*):void {
					interaction(true);
				}, 
				onRemoved:Function = function (e:*):void {
					interaction(false);
				};
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			
			state = UP;
		}
		
		protected function interaction(on:Boolean):void {
			var func:Function = on ? this.addEventListener : this.removeEventListener;
			func(MouseEvent.CLICK, interactionHandler);
			func(MouseEvent.ROLL_OVER, interactionHandler);
			func(MouseEvent.ROLL_OUT, interactionHandler);
			func(MouseEvent.MOUSE_DOWN, interactionHandler);
			func(MouseEvent.MOUSE_UP, interactionHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, interactionHandler);
		}
		
		protected function interactionHandler(e:MouseEvent):void {
			switch (e.type) {
				case MouseEvent.CLICK : 
					state = CLICK;
					break;
				case MouseEvent.ROLL_OVER : 
					if (!_enabled) return;
					if (_state.state == StateWrapper.DOWN) return;
					state = OVER;
					break;
				case MouseEvent.ROLL_OUT : 
					if (!_enabled) return;
					if (_state.state == StateWrapper.DOWN) return;
					state = OUT;
					break;
				case MouseEvent.MOUSE_DOWN : 
					if (!_enabled) return;
					state = DOWN;
					stage.addEventListener(MouseEvent.MOUSE_UP, interactionHandler);
					break;
				case MouseEvent.MOUSE_UP : 
					if (!_enabled) return;
					state = UP;
					stage.removeEventListener(MouseEvent.MOUSE_UP, interactionHandler);
					break;
			}
			if (_on != null && (_onStates.indexOf(ALL) != -1 || _onStates.indexOf(_onState) != -1)) {
				var args:Array = [_onState, this];
				args.length = _on.length;
				_on.apply(this, args);
			}
		}
		
		override public function set width(value:Number):void {
			_state.width = value;
			super.width = value;
		}
		
		override public function set height(value:Number):void {
			_state.height = value;
			super.height = value;
		}
		
	}
}

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.utils.Dictionary;

class StateWrapper extends Sprite {
	
	public static const ALL:int = -1;
	public static const UP:int = 1;
	public static const OVER:int = 2;
	public static const DOWN:int = 3;
	public static const DISABLED:int = 4;
	
	protected static const DRAW_STYLE:Array = [
		{}, 
		{"color": 0xCCCCCC, "alpha": 1, "corner": 7},  
		{"color": 0xDDDDDD, "alpha": 1, "corner": 7}, 
		{"color": 0xBBBBBB, "alpha": 1, "corner": 7}, 
		{"color": 0xEEEEEE, "alpha": 1, "corner": 7}
	];
	
	protected var _asset:Dictionary = new Dictionary();
	
	protected var _state:int = UP;
	protected var _prevState:int = UP;
	protected var _w:Number = 0;
	protected var _h:Number = 0;
	
	public function setAsset(state:int, asset:*):void {
		var parsed:DisplayObject = parseAsset(asset);
		if (state == ALL) {
			_asset[state] = parsed ? parsed as MovieClip : null;
		} else {
			_asset[state] = parsed;
		}
		switchState();
	}
	
	protected function parseAsset(asset:*):DisplayObject {
		if (asset is DisplayObject) 
			return asset as DisplayObject;
		else if (asset is Class) 
			return new asset() as DisplayObject;
		return null;
	}
	
	public function set state(value:int):void {
		if (value >= UP && value <= DISABLED) {
			_prevState = _state;
			_state = value;
			switchState();
		}
	}
	
	protected function switchState():void {
		var asset:DisplayObject = getCurrentAsset();
		if (asset) {
			if (_w) asset.width = _w;
			if (_h) asset.height = _h;
			if (!contains(asset)) {
				while (numChildren) removeChildAt(0);
				addChildAt(asset, 0);
			}
		}
	}
	
	protected function getCurrentAsset():DisplayObject {
		if (_asset && _asset[ALL]) {
			_asset[ALL].gotoAndStop(_state);
			return _asset[ALL];
		} else {
			if (!_asset.hasOwnProperty(String(_state)) || !_asset[_state])
				_asset[_state] = draw(_state);
			return _asset[_state];
		}
	}
	
	public function get state():int {
		return _state;
	}
	
	public function get prevState():int {
		return _prevState;
	}
	
	protected function draw(state:int):Shape {
		var style:Object = DRAW_STYLE[state];
		var s:Shape = new Shape();
		s.graphics.beginFill(style.color, style.alpha);
		s.graphics.drawRoundRect(0, 0, 30, 24, style.corner, style.corner);
		s.graphics.endFill();
		return s;
	}
	
	override public function set width(value:Number):void {
		_w = value;
		if (_w && numChildren) getChildAt(0).width = _w;
	}
	
	override public function set height(value:Number):void {
		_h = value;
		if (_h && numChildren) getChildAt(0).height = _h;
	}
	
}