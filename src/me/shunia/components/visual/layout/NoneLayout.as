package me.shunia.components.visual.layout
{

	import me.shunia.components.Layout;
	import me.shunia.components.utils.Side;
	import me.shunia.components.utils.TwoD;

	/**
	 * 无布局状态下的布局计算
	 *  
	 * @author qingfenghuang
	 */	
	public class NoneLayout
	{
		protected static var p:TwoD = new TwoD();
		
		/**
		 * 计算布局
		 *  
		 * @param l 需要进行计算的layout实例
		 * @return 高宽
		 */	
		public static function layout(l:Layout):TwoD {
			return layoutInternal(l.elms, LayoutUtil.getPadding(l), l.align);
		}
		
		/**
		 * 内部方法,将业务方法公共化,可供外部调用并进行计算.
		 * 在计算布局的同时,该方法会默认将元素按照ALIGN_NONE进行位移处理.
		 *  
		 * @param elms 需要布局的元素数组,包含显示对象
		 * @param side 布局的padding配置
		 * @param gap 排列的间隔
		 * @return 计算之后的大小.
		 */		
		internal static function layoutInternal(elms:Array, side:Side, align:String):TwoD {
			var b:Side = new Side(), 
				elm:Object = null;
			
			for (var i:int = 0; i < elms.length; i ++) {
				elm = elms[i];
				// 因为NoneLayout只对Center这种情况做自动排列
				// 当Align为Center时,本质上是将所有子项归到左上角进行计算-
				// 即去除各个子项原本位置信息导致的无法计算的可能
				if (align == Layout.ALIGN_CENTER) 
					elm.x = elm.y = 0;
				if (b.left > elm.x) b.left = elm.x;
				if (b.right < (elm.x + elm.width)) b.right = elm.x + elm.width;
				if (b.top > elm.y) b.top = elm.y;
				if (b.bottom < (elm.y + elm.height)) b.bottom = elm.y + elm.height;
			}
			p.width = b.right - b.left + side.left + side.right;
			p.height = b.bottom - b.top + side.top + side.bottom;
			return p;
		}
		
		/**
		 * 计算子控件的排列方式
		 *  
		 * @param l 需要进行排列的layout实例
		 */	
		public static function align(l:Layout):void {
			alignInternal(l.elms, LayoutUtil.getPadding(l), new TwoD(l.width, l.height), l.align);
		}
		
		/**
		 * 内部方法,将业务方法公开化,可供外部调用并进行计算.
		 * 会根据提供的align方式,将元素进行排列.
		 * 该方法只会计算ALIGN_CENTER时的排列.
		 *  
		 * @param elms 需要排列的元素数组,包含显示对象
		 * @param side 排列的padding配置
		 * @param size 排列的尺寸限制
		 * @param align 横向上的排列方式,包括: </br>
		 * 				ALIGN_CENTER: 横纵向居中</br>
		 */		
		internal static function alignInternal(elms:Array, side:Side, size:TwoD, align:String):void {
			if (align == Layout.ALIGH_NONE || 
				align == Layout.ALIGN_FIRST || 
				align == Layout.ALIGN_LAST) return;
			var elm:Object = null, 
				w:Number = size.width - side.left - side.right, 
				h:Number = size.height - side.top - side.bottom;
			for (var i:int = 0; i < elms.length; i ++) {
				elm = elms[i];
				elm.y = (h - elm.height) / 2  + side.top;
				elm.x = (w - elm.width) / 2 + side.left; 
			}
		}
		
	}
}