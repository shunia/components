package me.shunia.components.visual.layout
{

	import me.shunia.components.Layout;
	import me.shunia.components.utils.Side;

	/**
	 * 布局计算工具类.
	 *  
	 * @author qingfenghuang
	 */	
	public class LayoutUtil
	{
		
		/**
		 * 获取布局中的padding属性,并组成新的Side对象,便于操作.
		 *  
		 * @param l 要布局的对象.
		 * @return Side对象,提供便捷统一的api来访问padding.
		 */		
		public static function getPadding(l:Layout):Side {
			var f:Side = new Side();
			
			f.left = l.paddingLeft <= 0 ? l.padding : l.paddingLeft;
			f.right = l.paddingRight <= 0 ? l.padding : l.paddingRight;
			f.top = l.paddingTop <= 0 ? l.padding : l.paddingTop;
			f.bottom = l.paddingBottom <= 0 ? l.padding : l.paddingBottom;
			
			return f;
		}
		
	}
}