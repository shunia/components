package me.shunia.components.visual.layout
{

	import me.shunia.components.Layout;
	import me.shunia.components.utils.Side;
	import me.shunia.components.utils.TwoD;

	/**
	 * 表格布局计算器
	 *  
	 * @author qingfenghuang
	 */
	public class GridLayout
	{
		
		/**
		 * 计算出来供align用 
		 */		
		protected static var _wrappers:Array = null;
		
		/**
		 * 计算布局
		 *  
		 * @param l 需要进行计算的layout实例
		 * @return 高宽
		 */	
		public static function layout(l:Layout):TwoD {
			// 根据column和row是否被定义来决定是在整体上采用纵向还是横向布局
			// 当以column为依据时,表明调用者是在横向布局上有要求,而纵向上进行扩展的意图,
			// 从而应该在整体上使用纵向布局,而单列里面采用横向布局: 
			// 		1, 2, 3, 4, 5
			//		6, 7, 8, 9, 10
			// 相对的,row表明应该在整体上使用横向布局,而单行里面采用纵向布局:
			// 		1, 3, 5, 7, 9
			//		2, 4, 6, 8, 10
			if (l.row > 0) {
				return rowLayout(l);
			} else {
				return columnLayout(l);
			}
		}
		
		private static function columnLayout(l:Layout):TwoD {
			var side:Side = LayoutUtil.getPadding(l), 
				p:TwoD = null;
			_wrappers = calculateColumns(l, side);
			
			// 拆开按组计算,每组都按横向布局计算
			for each (var wrapper:ColumnOrRowWrapper in _wrappers) {
				p = HorizontalLayout.layoutInternal(wrapper.elms, wrapper.side, wrapper.gap);
				wrapper.width = p.width;
				wrapper.height = p.height;
				HorizontalLayout.alignInternal(wrapper.elms, wrapper.side, p, wrapper.align);
			}
			
			// 把每组对象按纵向布局再计算
			p = VerticalLayout.layoutInternal(_wrappers, side, l.vGap);
			return p;
		}
		
		/**
		 * 把所有元素分组,按分组包裹成一个个的wrapper,用来提供布局计算的代理.
		 *  
		 * @param l layout布局的引用.
		 * @return 包含一个或多个ColumnOrRowWrapper对象的数组.
		 */		
		private static function calculateColumns(l:Layout, side:Side):Array {
			var column:int = 0;
			if (l.column > 0) {
				column = l.column;
			} else if (l.maxColumn > 0 && l.width) {	// 已做简单unit test
				// 计算一下能放下的column数,根据第一排计算
				var leftWidth:Number = l.width - side.left - side.right, 
					sumWidth:Number = 0, 
					preColumn:int = 0, 
					currentColumn:int = 0, 
					currentChild:Object = null;
				
				while (sumWidth < leftWidth) {
					currentChild = l.elms.length > currentColumn ? 
						l.elms[currentColumn] : null;
					if (currentChild) {
						sumWidth += currentChild.width + (currentColumn == 0 ? 0 : l.hGap);
						currentColumn ++;
						// 只有满足条件,才递增preColumn
						if (sumWidth < leftWidth) preColumn = currentColumn;
					} else {
						break;
					}
				}
				
				column = Math.max(l.maxColumn, preColumn);
			}
			
			return calculateWrappers(l.elms, column, l.align, l.hGap);
		}
		
		private static function rowLayout(l:Layout):TwoD {
			var side:Side = LayoutUtil.getPadding(l), 
				size:TwoD = new TwoD(l.width, l.height), 
				p:TwoD = null;
			_wrappers = calculateRows(l.elms, side, size, l.vGap, l.align, l.row, l.maxRow);
			
			// 拆开按组计算,每组都按横向布局计算
			for each (var wrapper:ColumnOrRowWrapper in _wrappers) {
				p = VerticalLayout.layoutInternal(wrapper.elms, wrapper.side, wrapper.gap);
				wrapper.width = p.width;
				wrapper.height = p.height;
				VerticalLayout.alignInternal(wrapper.elms, wrapper.side, p, wrapper.align);
			}
			
			// 把每组对象按纵向布局再计算
			p = HorizontalLayout.layoutInternal(_wrappers, side, l.vGap);
			return p;
		}
		
		/**
		 * 把所有元素分组,按分组包裹成一个个的wrapper,用来提供布局计算的代理.
		 *  
		 * @param l layout布局的引用.
		 * @return 包含一个或多个ColumnOrRowWrapper对象的数组.
		 */		
		private static function calculateRows(elms:Array, side:Side, size:TwoD, gap:int, align:String, row:int, maxRow:int):Array {
			var wrappers:Array = [], 
				finalRow:int = 0;
			if (row > 0) {
				finalRow = row;
			} else if (maxRow > 0 && size.height > 0) {	// 已做简单unit test
				// 计算一下能放下的column数,根据第一排计算
				var leftHeight:Number = size.height - side.top - side.bottom, 
					sumHeight:Number = 0, 
					preRow:int = 0, 
					currentRow:int = 0, 
					currentChild:Object = null;
				
				while (sumHeight < leftHeight) {
					currentChild = elms.length > currentRow ? 
						elms[currentRow] : null;
					if (currentChild) {
						sumHeight += currentChild.width + (currentRow == 0 ? 0 : gap);
						currentRow ++;
						// 只有满足条件,才递增preColumn
						if (sumHeight < leftHeight) preRow = currentRow;
					} else {
						break;
					}
				}
				
				finalRow = Math.max(maxRow, preRow);
			}
			
			return calculateWrappers(elms, finalRow, align, gap);
		}
		
		private static function calculateWrappers(elms:Array, columnOrRow:int, align:String, gap:int):Array {
			var wrappers:Array = [];
			
			if (columnOrRow != 0) {
				var line:int = Math.ceil(elms.length / columnOrRow), 
					i:int = 0, 
					l:int = 0, 
					wrapper:ColumnOrRowWrapper = null;
				while (l < line) {
					i = l * columnOrRow;
					wrapper = new ColumnOrRowWrapper();
					wrapper.align = align;
					wrapper.gap = gap;
					wrapper.side = new Side();
					var result:Array = [], 
						elm:Object = null, 
						lineEnds:int = (l + 1) * columnOrRow;
					lineEnds = (lineEnds + 1) > elms.length ? elms.length : lineEnds;
					while (i < lineEnds) {
						elm = elms[i];
						result.push(elm);
						i ++;
					}
					wrapper.elms = result;
					
					wrappers.push(wrapper);
					l ++;
				}
			}
			
			return wrappers;
		}
		
		/**
		 * 计算子控件的排列方式
		 *  
		 * @param l 需要进行排列的layout实例
		 */	
		public static function align(l:Layout):void {
			if (!_wrappers) return;
			var side:Side = LayoutUtil.getPadding(l), 
				p:TwoD = new TwoD(l.width, l.height);
			HorizontalLayout.alignInternal(_wrappers, side, p, l.align);
			VerticalLayout.alignInternal(_wrappers, side, p, l.align);
		}
	}
}

import me.shunia.components.utils.Side;

/**
 * 要拿这个类里的参数去做横纵向计算.
 *  
 * @author qingfenghuang
 */
class ColumnOrRowWrapper {
	
	protected var _elms:Array = null;
	protected var _side:Side = null;
	protected var _x:Number = 0;
	protected var _y:Number = 0;
	protected var _width:Number = 0;
	protected var _height:Number = 0;
	protected var _align:String = null;
	protected var _gap:int = 0;
	
	public function get elms():Array
	{
		return _elms;
	}

	public function set elms(value:Array):void
	{
		_elms = value;
	}

	public function get side():Side
	{
		return _side;
	}

	public function set side(value:Side):void
	{
		_side = value;
	}

	public function get x():Number
	{
		return _x;
	}

	public function set x(value:Number):void
	{
		var px:Number = _x;
		_x = value;
		_elms.forEach(function (item:Object, index:int, arr:Array):void {
			item.x = _x + item.x - px;
		});
	}

	public function get y():Number
	{
		return _y;
	}

	public function set y(value:Number):void
	{
		var py:Number = _y;
		_y = value;
		_elms.forEach(function (item:Object, index:int, arr:Array):void {
			item.y = _y + item.y - py;
		});
	}

	public function get width():Number
	{
		return _width;
	}

	public function set width(value:Number):void
	{
		_width = value;
	}

	public function get height():Number
	{
		return _height;
	}

	public function set height(value:Number):void
	{
		_height = value;
	}

	public function get align():String
	{
		return _align;
	}

	public function set align(value:String):void
	{
		_align = value;
	}

	public function get gap():int
	{
		return _gap;
	}

	public function set gap(value:int):void
	{
		_gap = value;
	}
}