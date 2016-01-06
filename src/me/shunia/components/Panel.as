package me.shunia.components {
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * 基本容器,用来代替Sprite使用,具备设置背景和计算布局的能力.
	 * 和Layou相互依赖,使用layout来进行布局计算和更新,
	 * 通过layout得到更新显示列表的消息,从而回来更新自己.
	 * 
	 * 此类可以和正常的显示对象兼容,唯一需要注意的是,此对象作为容器存在时,
	 * 添加和删除显示对象需要使用替代方法:
	 * 	add 
	 * 	remove
	 *  
	 * @author qingfenghuang
	 */	
	public class Panel extends Sprite{
		
		/**
		 * Panel用Layout来进行布局计算,这就是该layout的定义.
		 */		
	    protected var _layout:Layout = new Layout(paint);
		/**
		 * 可以启动debug模式来观察该控件的实际区域 
		 */		
		protected var _debug:Boolean = false;
		/**
		 * 设置的高宽 
		 */		
		protected var _w:int = 0;
		/**
		 * 设置的高宽 
		 */		
		protected var _h:int = 0;
		/**
		 * 可以设置背景,会自动计算尺寸并扩展 
		 */		
		protected var _bg:DisplayObject = null;
		/**
		 * 设置位图数据当背景 
		 */		
		protected var _bgGraphic:BitmapData = null;
		/**
		 * debug的时候用来画背景的颜色 
		 */		
		protected var _defaultPaintColor:uint = 0;
		/**
		 * debug的时候用来画背景的透明度 
		 */		
		protected var _defaultPaintAlpha:Number = 0;
		
		public function set lazyRender(value:Boolean):void {
			_layout._lazyRender = value;
		}
		
		/**
		 * 设置背景对象,目前支持显示对象实例和现实对象的类.
		 * 注意:该对象会根据计算或者设置的高宽属性而被缩放.
		 *  
		 * @param value 显示对象实例或者显示对象的类定义
		 */		
		public function set background(value:*):void {
			if (value == null) return;
			
			if (_bg && contains(_bg)) 
				removeChild(_bg);
			
			if (value is DisplayObject) 
				_bg = value;
			else if (value is Class) 
				_bg = new value();
			
			if (_bg && !contains(_bg)) {
				_bg.x = _bg.y = 0;
				addChildAt(_bg, 0);
			}
		}
		
		public function get background():* {
			return _bg;
		}
		
		public function set backgroundColor(value:uint):void {
			_defaultPaintColor = value;
		}
		
		public function set backgroundAlpha(value:Number):void {
			_defaultPaintAlpha = value;
		}
		
		override public function set width(value:Number):void {
			if (value != _w) {
				layout.width = _w = value;
				layout.updateDisplay();
			}
		}
		override public function get width():Number {
			return _w ? _w : _layout.width;
		}
		
		override public function set height(value:Number):void {
			if (value != _h) {
				layout.height = _h = value;
				layout.updateDisplay();
			}
		}
		override public function get height():Number {
			return _h ? _h : _layout.height;
		}
		
		public function set debug(value:Boolean):void {
			_debug = value;
			paint();
		}
		
		/**
		 * 所有对于容器布局的操作,全都通过获取layout的实例来代理.
		 *  
		 * @return 
		 */		
	    public function get layout():Layout {
	        return _layout;
	    }
		
		/**
		 * 当前子对象的数组.
		 *  
		 * @return 
		 */		
	    public function get elements():Array {
	        return _layout.elms;
	    }
		
		/**
		 * 替代显示对象的addChild方法,用来添加并维护子对象
		 *  
		 * @param d 需要添加的现实对象.
		 * @return 
		 */		
	    public function add(d:DisplayObject):DisplayObject {
			if (!contains(d)) {
		        addChild(d);
			}
			_layout.add(d);
	        return d;
	    }
		
		/**
		 * 替代显示对象的removeChild方法,用来删除并维护子对象
		 *  
		 * @param d
		 */		
		public function remove(d:DisplayObject):void {
			if (d && contains(d)) {
				removeChild(d);
				_layout.remove(d);
			}
		}
		
		/**
		 * 清空所有添加到布局中的显示对象.
		 * 
		 * 注意:background和本身的graphic不会清除. 
		 */		
		public function removeAll():void {
			lazyRender = true;
			while (elements.length) {
				remove(elements.shift() as DisplayObject);
			}
			lazyRender = false;
			_layout.updateDisplay();
		}
		
		/**
		 * 每次layout计算过布局就会调用这个方法来更新背景区域,可以方便获取此控件的高宽.<br/>
		 * 可以覆写来实现自己的更新逻辑.
		 */		
		protected function paint():void {
			if (_bg) {
				_bg.width = width;
				_bg.height = height;
			}
			if (!_bg) {
				graphics.clear();
				var c:uint = _debug ? Math.random() * 0xFFFFFF : _defaultPaintColor;
				var a:Number = _debug ? 1 : _defaultPaintAlpha;
				graphics.beginFill(c, a);
				graphics.drawRect(0, 0, width, height);
				graphics.endFill();
			}
		}
		
		/**
		 * 清空该容器,使其回到初始不含任何现实对象,并且本身也不具备任何显示属性的状态.
		 * 
		 * 注意:不清空layout及其相关属性. 
		 */		
	    public function clear():void {
			removeAll();
	        while (numChildren) removeChildAt(0);
	        graphics.clear();
	    }
	
	}
}
