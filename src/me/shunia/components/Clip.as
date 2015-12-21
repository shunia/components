package me.shunia.components
{

	import flash.display.Shape;

	/**
	 * 带遮罩基础容器.修改了get的高宽属性.
	 * 但是因为显示对象列表本身的特性(脏矩形计算),所以不会影响它在显示列表中的实际高宽.
	 * 所以使用此控件需要手动计算layout才能避开显示列表的高宽渲染.
	 * 另外基于这种特殊性,不建议修改该容器坐标,尤其是需要使用getRect之类的方法的时候.<br/>
	 * 
	 * @author qingfenghuang
	 */	
	public class Clip extends Panel
	{
		
		protected var _mask:Shape = null;
		
		public function Clip()
		{
			super();
			name = "clip";
			// 初始化mask.
			updateMask();
		}
		
		protected function updateMask():void {
			if (!_mask) {
				_mask = new Shape();
				_mask.name = "clip_mask";
				addChild(_mask);
				this.mask = _mask;
			}
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0 ,0);
			_mask.graphics.drawRect(0, 0, _w, _h);
			_mask.graphics.endFill();
		}
		
		override public function set width(value:Number):void {
			super.width = value;
			updateMask();
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			updateMask();
		}
		
		override public function get width():Number {
			return _w;
		}
		
		override public function get height():Number {
			return _h;
		}
		
		public function get contentWidth():Number {
			return _layout.width;
		}
		
		public function get contentHeight():Number {
			return _layout.height;
		}
		
	}
}