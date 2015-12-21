package me.shunia.components
{

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import me.shunia.components.utils.PropConfig;

	/**
	 * 支持对一个对象增加滚动条功能.
	 *  
	 * @author qingfenghuang
	 */	
	public class Scroller extends Panel
	{
		
		private static const WHEEL_GAP_SCALE:Number = 0.03;
		
		public static const VERTICAL:String = Layout.VERTICAL;
		public static const HORIZONTAL:String = Layout.HORIZONTAL;
		public static const PREFER_TOP:String = "top";
		public static const PREFER_BOTTOM:String = "bottom";
		public static const BAR_INNER:String = "inner";
		public static const BAR_OUT:String = "inner";
		
		public static const P_HEIGHT:String = "height";
		public static const P_WIDTH:String = "width";
		public static const P_DIRECTION:String = "direction";
		public static const P_CONTENT:String = "content";
		public static const P_PREFER_DIRECTION:String = "barPreferDirection";
		public static const P_AUTO_SCROLL:String = "autoScroll";
		public static const P_BAR_POSITION:String = "barPosition";
		
		protected var _props:PropConfig = null;
		protected var _clip:Clip = null;
		protected var _content:DisplayObject = null;
		protected var _bar:ScrollerBar = null;
		protected var _lock:Boolean = false;
		protected var _direction:String = null;
		protected var _prefer:String = null;
		protected var _autoScroll:Boolean = false;
		
		protected var _lastWidth:Number = 0;
		protected var _lastX:Number = 0;
		protected var _lastHeight:Number = 0;
		protected var _lastY:Number = 0;
		
		protected var _lastContentSize:Rectangle = null;
		protected var _lastClipSize:Rectangle = null;
		protected var _contentSize:Rectangle = null;
		protected var _clipSize:Rectangle = null;
		
		public function Scroller()
		{
			super();
			name = "scroller";
			_props = new PropConfig();
			_clip = new Clip();
			_bar = new ScrollerBar();
			_direction = VERTICAL;
			_prefer = PREFER_TOP;
			_lastContentSize = new Rectangle();
			_lastClipSize = new Rectangle();
		}
		
		public function set lock(value:Boolean):void {
			_lock = value;
		}
		
		public function setProp(k:String, value:*):Scroller {
			_props.setProp(k, value);
			return this;
		}
		
		public function setPropDelegation(props:PropConfig):Scroller {
			_props = props;
			return this;
		}
		
		public function update():Scroller {
			clearEvents();
			updateProps();
			updateClipAndContent();
			updatePrefer();
			updateBar();
			onUpdateLayout();
			onEvents();
			return this;
		}
		
		/**
		 * TODO 
		 * 临时方法,目前在不autoScroll的情况下不会刷新bar.
		 */		
		public function forceUpdate():void {
			updatePrefer();
			updateBar();
			layout.updateDisplay();
		}
		
		protected function clearEvents():void {
			removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function updateProps():void {
			// DIRECTION不删除,用来传递给ScrollerBar
			if (_props.hasProp(P_DIRECTION)) _direction = _props.safeProp(P_DIRECTION, _direction);
			if (_props.hasProp(P_PREFER_DIRECTION)) _prefer = _props.safeProp(P_PREFER_DIRECTION, _prefer);
			// 更新当前控件本身的方向,用来排列遮罩区域和滚动条
			if (_direction == VERTICAL) layout.type = HORIZONTAL;
			else layout.type = VERTICAL;
			// 是否自动更新
			if (_props.hasProp(P_AUTO_SCROLL)) _autoScroll = _props.safeProp(P_AUTO_SCROLL, _autoScroll);
		}
		
		protected function updateClipAndContent():void {
			var clipSizeSetted:Boolean = true;
			// 更新遮罩区域尺寸
			if (_props.hasProp(P_HEIGHT)) _clip.height = _props.safeProp(P_HEIGHT, height);
			else clipSizeSetted = false;
			if (_props.hasProp(P_WIDTH)) _clip.width = _props.safeProp(P_WIDTH, width);
			else clipSizeSetted = false;
			// 更新clip的方向,添加子元素的时候会自动排序
			_clip.layout.type = _direction;
			// 添加子对象
			if (_props.hasProp(P_CONTENT)) _content = _props.safeProp(P_CONTENT, _content);
			if (_content && !_clip.contains(_content)) {
				// 假如没有设置高宽,就用初始状态下content的默认高宽作为尺寸
				if (!clipSizeSetted) {
					_clip.width = _content.width;
					_clip.height = _content.height;
				}
				_clip.removeAll();
				_clip.add(_content);
			}
			
			if (!contains(_clip)) add(_clip);
		}
		
		protected function updateBar():void {
			if (!_content) return;
			
			_bar.setPropDelegation(_props)
				.setProp(ScrollerBar.P_VIEW_SIZE, clipSizeTmp)
				.setProp(ScrollerBar.P_CONTENT_SIZE, contentSizeTmp)
				.setProp(ScrollerBar.P_ON_UPDATE, onScrolling)
				.update();
			
			if (!contains(_bar)) add(_bar);
		}
		
		protected function onUpdateLayout():void {
			layout.updateDisplay();
		}
		
		protected function onEvents():void {
			addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function onWheel(e:MouseEvent):void {
			if (!_content) return;
			if (_direction == VERTICAL && contentSize.height <= clipSize.height) return;
			if (_direction == HORIZONTAL && contentSize.width <= clipSize.width) return;
			
			var dx:Number = 0, dy:Number = 0;
			var offset:Number = e.delta * WHEEL_GAP_SCALE * _content.height;
			if (_direction == VERTICAL) dy = offset;
			else dx = offset;
			offsetContent(-dx, -dy);
			updateBar();
		}
		
		protected function onEnterFrame(e:Event):void {
			if (!_content) return;
			
			if (!_lastContentSize.size.equals(contentSize.size) || !_lastClipSize.size.equals(clipSize.size)) {
				cloneRectTo(_lastContentSize, contentSize);
				cloneRectTo(_lastClipSize, clipSize);
				
				if (_autoScroll) 
					updatePrefer();
				updateBar();
			}
		}
		
		/**
		 * 复制rect属性.
		 *  
		 * @param source
		 * @param target
		 */		
		protected function cloneRectTo(source:Rectangle, target:Rectangle):void {
			source.x = target.x;
			source.y = target.y;
			source.width = target.width;
			source.height = target.height;
		}
		
		protected function updatePrefer():void {
			if (_lock) return;
			if (_direction == HORIZONTAL) {
				if (contentSize.width > clipSize.width) {
					if (_prefer == PREFER_BOTTOM) 
						_content.x = _clip.width - _content.width;
					else 
						_content.x = 0;
				} else 
					_content.x = 0;
			} else {
				if (contentSize.height > clipSize.height) {
					if (_prefer == PREFER_BOTTOM) 
						_content.y = _clip.height - _content.height;
					else 
						_content.y = 0;
				} else 
					_content.y = 0;
			}
		}
		
		protected function onScrolling(dx:Number, dy:Number):void {
			offsetContent(dx, dy);
		}
		
		protected function offsetContent(dx:int, dy:int):void {
			_content.x -= dx;
			// 范围限定
			var cts:Rectangle = contentSizeTmp, cls:Rectangle = clipSizeTmp;
			if (_direction == HORIZONTAL && cts.left > 0) 
				_content.x = 0;
			if (_direction == HORIZONTAL && cts.right < cls.width) 
				_content.x = cls.height - cts.height;
			_content.y -= dy;
			// 范围限定
			cts = contentSizeTmp, cls = clipSizeTmp;
			if (_direction == VERTICAL && cts.top > 0) 
				_content.y = 0;
			if (_direction == VERTICAL && cts.bottom < cls.height) 
				_content.y = cls.height - cts.height;
			
			dispatchEvent(new CompEvents(CompEvents.CHANGE));
		}
		
		public function get contentSizeTmp():Rectangle {
			return contentSize.clone();
		}
		
		public function get contentSize():Rectangle {
			if (!_content) {
				if (!_contentSize) _contentSize = new Rectangle();
				else _contentSize.setEmpty();
			} else {
				if (!_contentSize) _contentSize = new Rectangle();
				_contentSize.x = _content.x;
				_contentSize.y = _content.y;
				_contentSize.width = _content.width;
				_contentSize.height = _content.height;
			}
			return _contentSize;
		}
		
		public function get clipSizeTmp():Rectangle {
			return clipSize.clone();
		}
		
		public function get clipSize():Rectangle {
			if (!_clip) {
				if (!_clipSize) _clipSize = new Rectangle();
				else _clipSize.setEmpty();
			} else {
				if (!_clipSize) _clipSize = new Rectangle();
				_clipSize.x = _clip.x;
				_clipSize.y = _clip.y;
				_clipSize.width = _clip.width;
				_clipSize.height = _clip.height;
			}
			return _clipSize;
		}
		
		override public function get width():Number {
			return clipSize.width;
		}
		
		override public function get height():Number {
			return clipSize.height;
		}
		
	}
}