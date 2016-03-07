package me.shunia.components
{

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import me.shunia.components.interfaces.IItemRenderHolder;
	import me.shunia.components.interfaces.IItemRender;
	import me.shunia.components.utils.Side;
	import me.shunia.components.visual.layout.LayoutUtil;

	[Event(type="me.shunia.components.CompEvents", name="itemClick")]
	
	/**
	 * 可以使用数据来进行更新的List控件,通过提供IItemRender的继承类来进行最终渲染,提供数组数据来触发创建和更新.
	 *  
	 * @author qingfenghuang
	 */	
	public class DataList extends List implements IItemRenderHolder
	{
		
		protected var _data:Array = null;
		protected var _render:Class = null;
		protected var _sort:Function = null;
		protected var _item:IItemRender = null;
		protected var _selectedIndex:int = -1;
		protected var _selectedItem:IItemRender = null;
		
		protected var _p:Point = new Point();
		
		public function DataList()
		{
			super();
			_data = [];
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		protected function onAdded(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		protected function onRemoved(e:Event):void {
			// 强制清除选中项的样式
			if (_selectedItem) _selectedItem.onMouseOut();

			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		public function set sortFunc(value:Function):void {
			// 只能接受2个参数的回调方法才符合要求
			if (value != null && value.length == 2) {
				_sort = function (item1:IItemRender, item2:IItemRender):Number {
					return value.apply(null, [item1.data, item2.data]);
				};
			}
		}
		
		public function set itemRenderer(value:Class):void {
			_render = value;
		}

		public function get itemRenderer():Class {
			return _render;
		}
		
		public function set data(value:Array):void {
			removeAll();
			_data = [];
			
			addItemsByData(value);
			selectedIndex = 0;
		}
		
		public function get data():Array {
			return _data;
		}
		
		public function set selectedIndex(value:int):void {
			if (value < -1) value = -1;
			if (_selectedIndex != value) {
				_selectedIndex = value;
				
				if ((_selectedIndex + 1) > elements.length) {
					// 越界了,限制到界内
					_selectedIndex = elements.length - 1;
				}

				onIndexChange();
			}
		}

		protected function onIndexChange():void {
			if (_selectedIndex == -1) _item = null;
			else _item = elements[_selectedIndex];

			_selectedItem = _item;
			if (_selectedItem) _selectedItem.onMouseOut();

			dispatchEvent(new CompEvents(CompEvents.CHANGE, true));
		}
		
		public function get selectedIndex():int {
			return _selectedIndex;
		}
		
		public function get selectedItem():IItemRender {
			return _selectedItem;
		}
		
		public function addItemsByData(data:*):void {
			if (!data) return;
			if (data == _data) return;
			
			if (!(data is Array || data is Vector)) data = [data];
			optAddItems(data);
		}
		
		public function addItemByData(data:*):void {
			if (!data) return;
			
			optAddItems([data]);
		}
		
		public function removeItemsByData(data:*):void {
			if (!data) {
				_data = [];
				removeItems(data);
				return;
			}
			
			if (data is Array || data is Vector) {
				var l:int = data.length,
					item:* = null;
				for (var i:int = 0; i < l; i ++) {
					item = data[i];
					removeItemByData(item);
				}
			} else 
				removeItemByData(data);
		}
		
		public function removeItemByData(data:*):void {
			if (!data) return;
			
			var contained:Boolean = false, 
				rendered:IItemRender = null, 
				elms:Array = null;
			if (data) {
				contained = _data.indexOf(data) != -1;
				if (contained) {
					elms = elements;
					for (var i:int = 0; i < elms.length; i ++) {
						rendered = elms[i] as IItemRender;
						if (rendered && rendered.data == data) {
							_data.splice(_data.indexOf(data), 1);
							removeItems(rendered);
						}
					}
				}
			}
		}
		
		public function sort():void {
			if (_sort == null) return;
			
			elements.sort(_sort);
			layout.updateDisplay();
		}
		
		public function dispose():void {
			_data = [];
			_render = null;
			removeItems(null);
		}
		
		protected function optAddItems(data:*):void {
			var rendered:Array = [], 
				accepted:Array = [], 
				l:int = data.length, 
				d:* = null, 
				s:DisplayObject = null, 
				contained:Boolean = false;
			
			for (var i:int = 0; i < l; i ++) {
				d = data[i];
				// 排重
				if (_data.indexOf(d) == -1) {
					s = render(d) as DisplayObject;
				
					accepted.push(d);
					rendered.push(s);
				}
			}
			
			// 更新数据源
			_data = _data.concat(accepted);
			// 添加相应的显示对象
			addItems(rendered);
		}
		
		override protected function postLazyRenderList():void {
			// 在准备更新列表时对排列元素提前做排序,最小限度的降低对性能的影响
			sort();
			// 开始更新
			super.postLazyRenderList();
			// 再设置高宽(因为最大高宽已经被layout算出来了)
			resizeAllChildren();
		}
		
		/**
		 * 尝试用统一的高宽对其所有子对象. 
		 */		
		protected function resizeAllChildren():void {
			var c:Number = 0, 
				s:Side = LayoutUtil.getPadding(layout);
			if (layout.type == Layout.VERTICAL) {
				c = width - s.left - s.right;
			} else {
				c = height - s.top - s.bottom;
			}
			for (var i:int = 0; i < elements.length; i ++) {
				if (layout.type == Layout.VERTICAL) {
					if (elements[i].width != c) 
						elements[i].width = c;
					elements[i].height = elements[i].height;
				} else {
					if (elements[i].height != c) 
						elements[i].height = c;
					elements[i].width = elements[i].width;
				}
			}
		}
		
		internal function render(data:*):IItemRender {
			if (_render) {
				var r:IItemRender = new _render();
				r.data = data;
				return r;
			}
			return null;
		}
		
		override public function add(d:DisplayObject):DisplayObject {
			d = super.add(d);
			if (d is IItemRender) 
				addListen(d as IItemRender);
			return d;
		}
		
		override public function remove(d:DisplayObject):void {
			super.remove(d);
			if (d is IItemRender) 
				releaseListen(d as IItemRender);
		}
		
		override protected function paint():void {
			super.paint();
			
			// 生成默认的选中项
			if (_item) _selectedIndex = elements.indexOf(_item);
			if (_selectedIndex == -1) _item = null;
			else _item = elements[_selectedIndex];
		}
		
		protected function addListen(t:IItemRender):void {
			t.onRerender(onRender);
		}
		
		protected function releaseListen(t:IItemRender):void {
			t.onRerender(null);
		}
		
		protected function onOver(e:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		}
		
		/**
		 * 统一管理子项的鼠标效果,避免大量监听
		 *  
		 * @param e
		 */		
		protected function onMove(e:MouseEvent):void {
			_p.x = e.stageX;
			_p.y = e.stageY;
			var item:Array = stage.getObjectsUnderPoint(_p);
			if (item && item.length) {
				var d:IItemRender = null, 
					tmp:IItemRender = null;
				for (var i:int = 0; i < item.length; i ++) {
					if (item[i] is IItemRender && item[i] is _render) {
						tmp = item[i] as IItemRender;
						if (this.contains(tmp as DisplayObject)) {
							d = tmp;
							break;
						}
					}
				}
				if (d) {
					if (_item != d)
						onOutItem(_item)
					onOverItem(d);
					_item = d;
				} else {
					onOutItem(_item);
					_item = null;
					_selectedItem = null;
				}
			}
		}
		
		protected function onOut(e:MouseEvent):void {
			onOutItem(_item);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
		}

		protected function onOverItem(item:IItemRender):void {
			if (item) {
				item.onMouseOver();
				var e:CompEvents = new CompEvents(CompEvents.ITEM_OVER, true);
				e.params = [item];
				dispatchEvent(e);
			}
		}

		protected function onOutItem(item:IItemRender):void {
			if (item) {
				item.onMouseOut();
				var e:CompEvents = new CompEvents(CompEvents.ITEM_OUT, true);
				e.params = [item];
				dispatchEvent(e);
			}
		}
		
		protected function onClick(e:MouseEvent):void {
			if (_item) {
				_selectedItem = _item;
				_selectedItem.onMouseClick();
				selectedIndex = elements.indexOf(_item);
				var ce:CompEvents = new CompEvents(CompEvents.ITEM_CLICK, true);
				ce.params = [_selectedItem];
				dispatchEvent(ce);
			}
		}
		
		protected function onRender(item:IItemRender):void {
			var e:CompEvents = new CompEvents(CompEvents.ITEM_UPDATE, true);
			e.params = [item];
			dispatchEvent(e);
		}
		
	}
}