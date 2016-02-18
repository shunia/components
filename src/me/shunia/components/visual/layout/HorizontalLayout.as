package me.shunia.components.visual.layout
{

	import me.shunia.components.Layout;
	import me.shunia.components.utils.Side;
	import me.shunia.components.utils.TwoD;
	import me.shunia.components.visual.layout.LayoutUtil;

	/**
	 * 横向布局计算器
	 *  
	 * @author qingfenghuang
	 */
	public class HorizontalLayout
	{
		
		protected static var p:TwoD = new TwoD();
		
		/**
		 * 计算布局
		 *  
		 * @param l 需要进行计算的layout实例
		 * @return 高宽
		 */	
		public static function layout(l:Layout):TwoD {
			var g:int = LayoutUtil.getGap(l, Layout.HORIZONTAL);
			if (g != l.hGap) trace(l.hGap + "=>" + g);
			return layoutInternal(l.elms, LayoutUtil.getPadding(l), g);
		}
		
		/**
		 * 内部方法,将业务方法公共化,可供外部调用并进行计算.
		 * 在计算横向布局的同时,该方法会默认将元素按照ALIGN_FIRST进行位移处理.
		 *  
		 * @param elms 需要布局的元素数组,包含显示对象
		 * @param side 布局的padding配置
		 * @param gap 排列的间隔
		 * @return 计算之后的大小.
		 */		
		internal static function layoutInternal(elms:Array, side:Side, gap:int):TwoD {
			var mh:Number = 0, 
				mw:Number = 0, 
				elm:Object = null, 
				lastElm:Object = null;
			
			for (var i:int = 0; i < elms.length; i ++) {
				elm = elms[i];
				elm.x = lastElm ? lastElm.x + lastElm.width + gap : side.left;
				elm.y = side.top;
				mh = Math.max(mh, elm.y + elm.height + side.bottom);
				lastElm = elm;
			}
			mw = lastElm ? lastElm.x + lastElm.width + side.right : 0;
			p.width = mw;
			p.height = mh;
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
		 *  
		 * @param elms 需要排列的元素数组,包含显示对象
		 * @param side 排列的padding配置
		 * @param size 排列的尺寸限制
		 * @param align 纵向上的排列方式,包括: </br>
		 * 				ALIGN_FIRST: 纵向居顶</br>
		 * 				ALIGN_CENTER: 纵向居中</br>
		 * 				ALIGN_LAST: 纵向居底</br>
		 */		
		internal static function alignInternal(elms:Array, side:Side, size:TwoD, align:String):void {
			if (align == Layout.ALIGH_NONE || align == Layout.ALIGN_FIRST) return;
			// 居中需要重新过一遍,计算一下纵向上的位置
			var h:Number = size.height - side.top - side.bottom, 
				elm:Object = null;
			for (var i:int = 0; i < elms.length; i ++) {
				elm = elms[i];
				if (align == Layout.ALIGN_CENTER) 
					elm.y = (h - elm.height) / 2 + side.top;
				else if (align == Layout.ALIGN_FIRST) 
					elm.y = side.top;
				else if (align == Layout.ALIGN_LAST) 
					elm.y = (h - elm.height) - side.bottom;
			}
		}
		
	}
}