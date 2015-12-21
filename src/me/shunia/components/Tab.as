package me.shunia.components
{

	import flash.display.DisplayObject;

	[Event(name="itemClick", type="me.shunia.components.CompEvents")]
	
	/**
	 * Tab按钮控件.
	 * 
	 * @author qingfenghuang 
	 */	
	public class Tab extends Panel
	{
		
		protected var _selected:int = -1;
		protected var _onButtonCreation:Function = null;
		protected var _btnCls:Class = null;
		
		public function Tab()
		{
			super();
		}
		
		/**
		 * 当前选中的按钮index.基于0.
		 *  
		 * @return 
		 */		
		public function get selectedIndex():int {
			return _selected;
		}
		
		/**
		 * 基于0的按钮index,设置后可能会改变当前选中的按钮. 
		 * @param value
		 */		
		public function set selectedIndex(value:int):void {
			_selected = value;
			updateStatus();
		}
		
		/**
		 * 当前选中的视图 
		 * @return 
		 */		
		public function get selectedView():DisplayObject {
			if (elements && elements.length && elements.length >= (_selected + 1)) 
				return elements[_selected];
			return null;
		}
		
		/**
		 * 设置创建按钮时的回调方法,可以在外部更新当前按钮.
		 * 该回调方法的参数需要接收一个按钮实例. 
		 * @param value
		 */		
		public function set onButtonCreation(value:Function):void {
			_onButtonCreation = value;
		}
		
		/**
		 * 设置创建按钮的类,用来创建自定义的按钮.
		 *  
		 * @param value
		 */		
		public function set buttonClass(value:Class):void {
			_btnCls = value;
		}
		
		/**
		 * 根据label添加按钮,后续应该做成类似DataList的形式,用itemRender和数据来创建tab
		 *  
		 * @param label
		 */		
		public function addItem(label:String):DisplayObject {
			var btn:Button = createButton(label);
			add(btn);
			updateStatus();
			return btn;
		}
		
		protected function createButton(label:String):Button {
			var cls:Class = _btnCls ? _btnCls : Button;
			var btn:Button = new cls() as Button;
			btn.label = label;
			btn.on(onClick);
			if (_onButtonCreation != null) _onButtonCreation.apply(null, [btn]);
			return btn;
		}
		
		private function onClick(state:int, btn:Button):void {
			selectedIndex = elements.indexOf(btn);
			dispatchEvent(new CompEvents(CompEvents.ITEM_CLICK));
		}
		
		protected function updateStatus():void {
			if (!elements) return;
			if (!elements.length) _selected = -1;
			if (_selected <= 0 || elements.length < (_selected + 1)) _selected = 0;
			
			var btn:Button = null;
			for (var i:int = 0; i < elements.length; i ++) {
				btn = elements[i] as Button;
				if (btn) {
					if (_selected == i) {
						btn.selected = true;
						btn.enabled = false;
					} else {
						btn.enabled = true;
						btn.selected = false;
					}
				}
			}
		}
		
	}
}