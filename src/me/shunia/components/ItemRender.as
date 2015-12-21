package me.shunia.components
{

	import me.shunia.components.interfaces.IItemRender;

	public class ItemRender extends Panel implements IItemRender
	{
		
		protected var _label:Label = null;
		protected var _data:Object = null;
		protected var _renderCallback:Function = null;
		
		public function ItemRender() {
			super();
			
			init();
		}
		
		protected function init():void {
			setupLayout();
			createChildren();
		}
		
		protected function setupLayout():void {
			
		}
		
		protected function createChildren():void {
			_label = new Label();
			add(_label);
		}
		
		public function set data(value:*):void {
			_data = value;
			render(_data);
		}
		
		public function get data():* {
			return _data;
		}
		
		protected function render(data:*):void {
			renderChildren(data);
			layout.updateDisplay();
			
			if (_renderCallback != null) 
				_renderCallback.apply(null, _renderCallback.length ? [this] : null);
		}
		
		protected function renderChildren(data:*):void {
			var s:String = null;
			if (data is String) s = data as String;
			if (data.hasOwnProperty("label")) s = data["label"]; 
			_label.text = s;
		}
		
		public function onMouseOver():void {
		}
		
		public function onMouseOut():void {
		}
		
		public function onMouseClick():void {
		}
		
		public function onRerender(callback:Function):void
		{
			_renderCallback = callback;
		}
		
	}
}