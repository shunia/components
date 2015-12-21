package me.shunia.components
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	import me.shunia.components.utils.PropConfig;
	import me.shunia.components.visual.Drag;

	/**
	 * 滚动条控件,理论上来说可以提供给任何显示对象用,前提是提供正确的参数.<br/>
	 * 必要参数: <br/>
	 * 	P_VIEW_SIZE
	 * 	P_CONTENT_SIZE
	 * 	P_ASSET_TRACK
	 * 	P_ASSET_THUMB
	 * <br/>
	 * 可选参数: <br/>
	 * 	P_DIRECTION 默认为纵向 <br/>
	 * 	P_ON_UPDATE 滚动条滚动后的回调函数,实际情况下应该是必要参数 <br/>
	 * 	P_ALWAYS_SHOW 是否一直显示滚动条 <br/>
	 * @author qingfenghuang
	 */	
	public class ScrollerBar extends Sprite
	{
		
		public static const VERTICAL:String = Layout.VERTICAL;
		public static const HORIZONTAL:String = Layout.HORIZONTAL;
		
		/**
		 * 滚动条方向,纵向或者横向 
		 */		
		public static const P_DIRECTION:String = "direction";
		/**
		 * 此滚动条要管理的对象的可视区域尺寸,类型为Rectangle 
		 */		
		public static const P_VIEW_SIZE:String = "viewSize";
		/**
		 * 此滚动条要管理的对象的实际(内容)区域尺寸,类型为Rectangle 
		 */		
		public static const P_CONTENT_SIZE:String = "contentSize";
		/**
		 * 滚动槽的素材,可以是显示对象或者显示对象的类(Class) 
		 */		
		public static const P_ASSET_TRACK:String = "assetTrack";
		/**
		 * 滚动条的素材(可拖拽部分),可以是显示对象或者现实对象的类(Class) 
		 */		
		public static const P_ASSET_THUMB:String = "assetThumb";
		/**
		 * 拖动时触发的回调方法,如果需要用拖动来触发外部容器的位置信息更新,需要注册此方法,参数为两个:dx, dy 
		 */		
		public static const P_ON_UPDATE:String = "onUpdate";
		/**
		 * 是否一直显示此控件,如果设为false,当可视区域大于等于内容区域时会隐藏控件 
		 */		
		public static const P_ALWAYS_SHOW:String = "alwaysShow";
		
		protected var _viewSize:Rectangle = null;
		protected var _contentSize:Rectangle = null;
		protected var _direction:String = null;
		protected var _prefer:String = null;
		protected var _track:DisplayObject = null;
		protected var _thumb:DisplayObject = null;
		protected var _trackSize:Rectangle = null;
		protected var _thumbSize:Rectangle = null;
		protected var _drag:Drag = null;
		protected var _cb:Function = null;
		protected var _show:Boolean = false;
		
		private var _scale:Number = 1;
		
		protected var _props:PropConfig = null;
		
		public function ScrollerBar()
		{
			super();
			_props = new PropConfig();
			_trackSize = new Rectangle();
			_thumbSize = new Rectangle();
			_direction = VERTICAL;
		}
		
		public function isDragging():Boolean {
			return _drag ? false : _drag.isDragging;
		}
		
		public function setProp(key:String, value:*):ScrollerBar {
			_props.setProp(key, value);
			return this;
		}
		
		public function setPropDelegation(props:PropConfig):ScrollerBar {
			_props = props;
			return this;
		}
		
		public function update():void {
			updateSize();
			updateBar();
			calculateAndApply();
			onEvent();
		}
		
		protected function updateSize():void {
			if (_props.hasProp(P_VIEW_SIZE)) _viewSize = _props.safeProp(P_VIEW_SIZE, _viewSize);
			if (_props.hasProp(P_CONTENT_SIZE)) _contentSize = _props.safeProp(P_CONTENT_SIZE, _contentSize);
		}
		
		protected function updateBar():void {
			var track:*, thumb:*;
			track = _props.safeProp(P_ASSET_TRACK);
			track = toDisplayObject(track);
			thumb = _props.safeProp(P_ASSET_THUMB);
			thumb = toDisplayObject(thumb);
			// 啥也没有,不管了
			if (!track && !thumb) return;
			// 删除了重新创建
			if (_drag) _drag.dispose();
			while (numChildren) removeChildAt(0);
			if (track) _track = track;
			addChild(_track);
			if (thumb) _thumb = thumb;
			addChild(thumb);
		}
		
		protected function toDisplayObject(o:*):DisplayObject {
			var d:DisplayObject = null;
			if (o) {
				if (o is Class) {
					d = new o() as DisplayObject;
				} else if (o is DisplayObject) {
					d = o as DisplayObject;
				}
			}
			return d;
		}
		
		protected function calculateAndApply():void {
			// 区分一下横纵向,可以更明确
			if (_props.hasProp(P_DIRECTION)) _direction = _props.safeProp(P_DIRECTION, _direction);
			// 根据方向计算
			_direction == VERTICAL ? onVerticalCalculation() : onHorizontalCalculation();
			// 更新
			_track.x = _trackSize.x;
			_track.y = _trackSize.y;
			_track.width = _trackSize.width;
			_track.height = _trackSize.height;
			_thumb.x = _thumbSize.x;
			_thumb.y = _thumbSize.y;
			_thumb.width = _thumbSize.width;
			_thumb.height = _thumbSize.height;
			// 是否显示此控件
			// TODO : qingfenghuang
			if (_props.hasProp(P_ALWAYS_SHOW)) _show = _props.safeProp(P_ALWAYS_SHOW, _show);
			if (_show) visible = true;
			else if (_thumbSize.width >= _trackSize.width && _thumbSize.height >= _trackSize.height) visible = false;
			else visible = true;
		}
		
		/**
		 * 方向为垂直时的计算方法 
		 */		
		protected function onVerticalCalculation():void {
			if (_contentSize.height < _viewSize.height) _contentSize.height = _viewSize.height;
			
			_trackSize.setEmpty();
			_trackSize.width = _track.width;
			_trackSize.height = _viewSize.height;
			_thumbSize.setEmpty();
			_thumbSize.width = _track.width;
			_scale = _viewSize.height == 0 ? 0 : _contentSize.height / _viewSize.height;
			_thumbSize.height = _viewSize.height == 0 ? 0 : _viewSize.height / _contentSize.height * _viewSize.height;
			_thumbSize.x = (_track.width - _thumb.width) / 2;
			// 用可视区域比总区域
			_thumbSize.y = Math.abs(_contentSize.top - _viewSize.top) / _contentSize.height * _viewSize.height;
		}
		
		/**
		 * 方向为水平时的计算方法 
		 */		
		protected function onHorizontalCalculation():void {
			if (_contentSize.width < _viewSize.width) _contentSize.width = _viewSize.width;
			
			_trackSize.setEmpty();
			_trackSize.height = _track.height;
			_trackSize.width = _viewSize.width;
			_thumbSize.setEmpty();
			_thumbSize.height = _thumb.height;
			_scale = _viewSize.width == 0 ? 0 : _contentSize.width / _viewSize.width;
			_thumbSize.width = _viewSize.width == 0 ? 0 : _viewSize.width / _contentSize.width * _viewSize.width;
			_thumbSize.y = (_track.height - _thumb.height) / 2;
			// 用可视区域比总区域
			_thumbSize.x = Math.abs(_contentSize.left - _viewSize.left) / _contentSize.width * _viewSize.width;
		}
		
		protected function onEvent():void {
			if (!_drag) _drag = new Drag();
			_drag.setUp(_thumb, onScroll);
			_drag.start();
			if (_props.hasProp(P_ON_UPDATE)) _cb = _props.safeProp(P_ON_UPDATE, _cb);
		}
		
		protected function onScroll(dx:Number, dy:Number):void {
			if (_direction == VERTICAL) {
				if (_thumb.height == _track.height) return;	// 优化,当滚动条处于条和槽长度相等时,不做处理
				dx = 0;
			} else {
				if (_thumb.width == _track.width) return;
				dy = 0;
			}
			if (_cb != null) _cb.apply(this, [Math.round(dx * _scale), Math.round(dy * _scale)]);
		}
		
	}
}