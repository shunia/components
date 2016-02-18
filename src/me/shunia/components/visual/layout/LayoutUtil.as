package me.shunia.components.visual.layout
{

	import flash.display.DisplayObject;

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

		/**
		 * 为横向或者纵向布局计算服务，用来确认当使用或不使用autoGap时在某个方向上
		 * 的计算gap值。
		 *
		 * @param l 要布局的对象
		 * @param type 布局的方向 HORIZONTAL或者VERTICAL
		 * @return 计算出来的gap值
		 * */
		public static function getGap(l:Layout, type:String):int {
			var w:Number = 0, h:Number = 0, s:Side = null;

			if (type == Layout.HORIZONTAL) {
				if (l.autoGap) {
					if (l.wDirty) w = l.width;
					else if (l.root) {
						if (l.root.parent) {
							w = l.root.parent.width;
							s = getTargetPadding(l.root.parent);
						} else {
							w = l.root.width;
							s = getTargetPadding(l.root);
						}
						if (s) {
							w = w - s.left - s.right;
						}

						if (!w) return l.hGap;
					}

					if (w) {
						var mw:Number = 0;
						for (var i:int = 0, li:int = l.elms.length; i < li; i++) {
							mw += l.elms[i].width;
						}
						mw = w - mw;
						if (mw > 0) return mw / (li > 1 ? li - 1 : 1);
					}
				}
				return l.hGap;
			} else if (type == Layout.VERTICAL) {
				if (l.autoGap) {
					if (l.hDirty) h = l.height;
					else if (l.root) {
						if (l.root.parent) {
							h = l.root.parent.height;
							s = getTargetPadding(l.root.parent);
						} else {
							h = l.root.height;
							s = getTargetPadding(l.root);
						}
						if (s) {
							h = h - s.top - s.bottom;
						}

						if (!h) return l.vGap;
					}

					if (h) {
						var mh:Number = 0;
						for (var j:int = 0, lj:int = l.elms.length; j < lj; j++) {
							mh += l.elms[j].height;
						}
						mh = h - mh;
						if (mh > 0) return mh / (lj > 1 ? lj - 1 : 1);
					}
				}
				return l.vGap;
			}

			return 0;
		}

		/**
		 * 尝试从目标对象身上找layout,并返回他的Padding
		 * */
		public static function getTargetPadding(root:DisplayObject):Side {
			if (root && root.hasOwnProperty("layout")) {
				var l:Layout = root["layout"];
				if (l)
					return getPadding(l);
			}
			return null;
		}
		
	}
}