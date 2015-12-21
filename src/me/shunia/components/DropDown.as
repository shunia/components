package me.shunia.components
{

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import me.shunia.components.interfaces.IItemRender;
	import me.shunia.components.utils.PropConfig;

	/**
	 * 需要拿里面的list来操作.除此以外跟Panel一样的使用方法.
	 *  
	 * @author qingfenghuang
	 */	
	public class DropDown extends Panel
	{
		
		public static const P_DROP_ALIGN:String = "dropAlign";
		public static const P_DROP_MODE:String = "dropMode";
		public static const P_LIST:String = "list";
		public static const P_ASSET_BACKGROUND:String = "assetBackground";
		public static const P_ASSET_DROP_BTN:String = "assetDropBtn";
		/**
		 * 用来提供给Dropdown单独绘制子项时用的.
		 * 主要用于Dropdown的子项和提供的List不共享一个Itemrenderer的情况.
		 * 比如提供的List使用的ItemRenderer是a,当List选中时,Dropdown
		 * 中需要用一个不同的ItemRenderer,比如b来渲染时,可以使用此属性,来提供
		 * 一个IItemRenderer的类或者实例,从而展现在Dropdown里. 
		 */		
		public static const P_ITEM_RENDERER:String = "itemRenderer";
		
		public static const MODE_TOP:int = 1;
		public static const MODE_BOTTOM:int = 2;
		public static const ALIGN_LEFT:int = 3;
		public static const ALIGN_RIGHT:int = 4;
		
		/**
		 * 管理的list实例 
		 */		
		protected var _list:DataList = null;
		/**
		 * 当前选中的item的镜像 
		 */		
		protected var _item:IItemRender = null;
		/**
		 * 下来的按钮,一般的下拉菜单都会有,没有也没问题 
		 */		
		protected var _dropBtn:DisplayObject = null;
		/**
		 * 当前是否处于打开状态 
		 */		
		protected var _isDropingDown:Boolean = false;
		/**
		 * 弹出方向,分为TOP和BOTTOM两种,顶部弹出和底部弹出 
		 */		
		protected var _mode:int = MODE_BOTTOM;
		/**
		 * 弹出框是居左还是居右弹出,分为LEFT和RIGHT 
		 */		
		protected var _align:int = ALIGN_LEFT;
		/**
		 * 绘制子项时使用的类定义 
		 */		
		protected var _itemRenderer:* = null;
		/**
		 * 指示是否更新了ItemRenderer属性 
		 */		
		protected var _itemRendererDirty:Boolean = false;
		
		protected var _props:PropConfig = null;
		
		public function DropDown()
		{
			super();
			
			layout.type = Layout.HORIZONTAL;
			layout.align = Layout.ALIGN_CENTER;
			
			_props = new PropConfig();
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		
		public function setProp(k:String, value:*):DropDown {
			_props.setProp(k, value);
			return this;
		}
		
		public function update():DropDown {
			updateProps();
			updateAssets();
			updateView();
			return this;
		}
		
		protected function updateProps():void {
			if (_props.hasProp(P_DROP_MODE)) _mode = _props.safeProp(P_DROP_MODE, _mode);
			if (_props.hasProp(P_DROP_ALIGN)) _align = _props.safeProp(P_DROP_ALIGN, _align);
			if (_props.hasProp(P_ITEM_RENDERER)) {
				var tmp:* = _props.safeProp(P_ITEM_RENDERER, null);
				if (_itemRenderer != tmp) {
					_itemRendererDirty = true;
					_itemRenderer = tmp;
				}
			}
		}
		
		protected function updateAssets():void {
			// list
			if (_props.hasProp(P_LIST)) {
				if (_list) {
					_list.removeEventListener(CompEvents.ITEM_CLICK, onItemClicked);
					_item = null;
				}
				_list = _props.safeProp(P_LIST, _list);
				_list.addEventListener(CompEvents.ITEM_CLICK, onItemClicked);
			}
			// 上下拉箭头
			if (_props.hasProp(P_ASSET_DROP_BTN)) _dropBtn = _props.safeProp(P_ASSET_DROP_BTN, _dropBtn);
			// 背景色
			if (_props.hasProp(P_ASSET_BACKGROUND)) background = _props.safeProp(P_ASSET_BACKGROUND, _bg);
		}
		
		public function updateView():void {
			lazyRender = true;
			
			removeAll();
			
			var selectedData:* = _list.selectedItem ? _list.selectedItem.data : null;
			if (selectedData) {
				if (_item && !_itemRendererDirty) 
					_item.data = selectedData;
				else {
					_itemRendererDirty = false;
					var render:* = _itemRenderer is Class ? new _itemRenderer() : _itemRenderer;
					var renderIns:IItemRender = render as IItemRender;
					if (!renderIns) renderIns = _list.render(selectedData);
					else renderIns.data = selectedData;
					_item = renderIns;
				}
				if (Object(_item).hasOwnProperty("mouseEnable")) _item["mouseEnable"] = false;
				add(_item as DisplayObject);
			}
			if (_dropBtn && !contains(_dropBtn)) 
				add(_dropBtn);
			onDropBtnChange();
			lazyRender = false;
			layout.updateDisplay();
		}
		
		protected function onDropBtnChange():void {
			if (_dropBtn && _dropBtn is MovieClip) {
				var mc:MovieClip = _dropBtn as MovieClip;
				if (mc.totalFrames > 1) {
					if (_isDropingDown) 
						mc.gotoAndStop(2);
					else 
						mc.gotoAndStop(1);
				}
			}
		}
		
		protected function onAdded(event:Event):void {
			stage.addEventListener(MouseEvent.CLICK, onCloseCheck);
			addEventListener(MouseEvent.CLICK, onOpenCheck);
		}
		
		protected function onRemoved(event:Event):void {
			stage.removeEventListener(MouseEvent.CLICK, onCloseCheck);
			removeEventListener(MouseEvent.CLICK, onOpenCheck);
		}
		
		protected function onOpenCheck(e:MouseEvent):void {
			if (!_isDropingDown && this.getBounds(stage).contains(e.stageX, e.stageY)) 
				showDropDown();
			else 
				hideDropDown();
		}
		
		protected function onCloseCheck(e:MouseEvent):void {
			if (_isDropingDown && 
				!this.getBounds(stage).contains(e.stageX, e.stageY) && 
				!_list.getBounds(stage).contains(e.stageX, e.stageY)) {
				hideDropDown();
			}
		}
		
		protected function onItemClicked(event:CompEvents):void {
			hideDropDown();
			updateView();
		}
		
		public function get selectedItem():IItemRender {
			return _item;
		}
		
		public function set dropMode(value:int):void {
			_mode = value < MODE_TOP ? MODE_TOP : value > MODE_BOTTOM ? MODE_BOTTOM : value;
		}
		
		public function set dropAlign(value:int):void {
			_align = value < ALIGN_LEFT ? ALIGN_LEFT : value > ALIGN_RIGHT ? ALIGN_RIGHT : value;
		}
		
		public function get list():DataList {
			return _list;
		}
		
		public function showDropDown():void {
			var r:Rectangle = this.getBounds(this), 
				p:Point = new Point();
			// 算y
			if (_mode == MODE_TOP) 
				p.y = r.y - _list.height;
			else 
				p.y = r.y + r.height;
			// 算x
			if (_align == ALIGN_LEFT) 
				p.x = r.x;
			else 
				p.x = r.width - _list.width;
			// 局部变全局,以应对层级导致的无法选中选项问题
			p = localToGlobal(p);
			// 更新坐标
			_list.x = p.x;
			_list.y = p.y;
			stage.addChild(_list);
			_isDropingDown = true;
			
			onDropBtnChange();
		}
		
		public function hideDropDown():void {
			if (stage.contains(_list)) stage.removeChild(_list);
			_isDropingDown = false;
			
			onDropBtnChange();
		}
		
	}
}