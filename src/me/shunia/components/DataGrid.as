package me.shunia.components
{

	import flash.display.DisplayObject;

	import me.shunia.components.interfaces.IDataComponent;
	import me.shunia.components.interfaces.IItemRender;

	/**
	 * Grid布局的,使用数据进行驱动的控件.
	 *  
	 * @author qingfenghuang
	 */	
	public class DataGrid extends Panel implements IDataComponent
	{
		
		protected var _itemRenderer:Class = ItemRender;
		protected var _data:Array = null;
		
		public function DataGrid()
		{
			super();
			// 预设布局类型,其他属性和参数根据需求赋值
			layout.type = Layout.GRID;
		}
		
		public function set data(value:Array):void
		{
			if (value != _data) {
				_data = value;
				// 先清空
				removeAll();
				// 逐个添加并布局
				if (_data && _data.length) {
					lazyRender = true;
					for (var i:int = 0; i < _data.length; i ++) {
						add(createItem(_data[i]) as DisplayObject);
					}
					lazyRender = false;
					layout.updateDisplay();
				}
			}
		}
		
		public function get data():Array
		{
			return _data;
		}
		
		public function set itemRenderer(value:Class):void {
			_itemRenderer = value;
		}
		
		protected function createItem(data:Object):IItemRender {
			var item:IItemRender = new _itemRenderer() as IItemRender;
			item.data = data;
			return item;
		}
		
	}
}