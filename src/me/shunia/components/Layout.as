package me.shunia.components {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import me.shunia.components.utils.TwoD;
	import me.shunia.components.visual.layout.GridLayout;
	import me.shunia.components.visual.layout.HorizontalLayout;
	import me.shunia.components.visual.layout.NoneLayout;
	import me.shunia.components.visual.layout.VerticalLayout;
	
	/**
	 * 通用布局类,通过设置需要的布局类型和布局参数等,实现对布局的计算.
	 * 和Panel相互依赖. </br>
	 * </br>
	 * 当需要对大量元素进行布局时,建议配合Panel.lazyRender属性使用,可以大幅度优化性能.
	 * 尤其是Grid布局.</br>
	 * </br>
	 * 原因是Layout使用实时计算的理念来处理布局变更,每当Panel中的子元素产生变化(增删),都
	 * 会对所有子对象重新进行布局计算.这种方法的优点在于无需等待渲染即可即时获得布局结果,便于
	 * 重叠布局时层层叠进,当前帧里所见即所得.</br>
	 * </br>
	 * 而Flex中的布局使用stage.invalidate事件作为更新触发的依据,该事件大部分情况下与布
	 * 局变化不是发生在同 一帧,如果使用AS重新实现的话,在没有绑定功能帮助的情况下,布局外部的对
	 * 象无法在合适的时机得到布局对象的正确布局属性,就会出现所见非所得的情况,另外还需要一些缓存
	 * 和管理的功能来保证异步渲染的正确性和衔接性.</br>
	 * </br>
	 * Layout本身是为简单易用正确为基础设计和实现的,其中缺失了传统UI布局控件系统中的管理功能(
	 * 由底至顶分步渲染,控件统一生命周期管理,布局相互依赖等),但这也正是Layout系统的理念,保证
	 * 每个控件和布局的高可用性和低依赖,最低限度的并且符合纯AS项目特色的实现布局功能.</br>
	 * </br>
	 * 目前List控件已经主动使用了Panel.lazyRender属性来优化性能.</br>
	 * </br>
	 * 使用例子:</br>
	 * 	var panel:Panel = new Panel();		// </br>
	 * 	panel.layout.type = Layout.GRID;	// 设置布局方式为表格式布局</br>
	 * 	panel.layout.column = 3;			// 设置表格的列数</br>
	 * 	panel.layout.hGap = 2;				// 设置每个子元素横向间距</br>
	 * 	panel.layout.vGap = 2;				// 设置每个子元素纵向间距</br>
	 * 	panel.layout.padding = 4;			// 设置所有子元素的边距</br>
	 * 	panel.layout.paddingTop = 6;		// 设置所有子元素的顶部边距,将会覆盖padding</br>
	 * 	</br>
	 * 	panel.lazyRender = true;			// 取消实时计算布局</br>
	 * 	for (var i:int = 0; i < 10; i ++) {	// </br>
	 * 		var s:Shape = new Shape();		// </br>
	 * 		s.graphics.beginFill(Math.random() * 0xFFFFFF, Math.random());	// </br>
	 * 		s.graphics.drawRect(0, 0, 30, 30);	// </br>
	 * 		s.graphics.endFill();			// </br>
	 * 		panel.add(s);					// </br>
	 * 	}</br>
	 * 	</br>
	 * 	panel.lazyRender = false;			// 恢复计算</br>
	 * 	panel.layout.updateDisplay();		// 手动触发一次计算,这时得到的就是最终布局</br>
	 * 	</br>
	 * 	addChild(panel);					// </br>
	 *  
	 * @author qingfenghuang
	 */	
	public class Layout {
		
		/**
		 * 表格式布局,使用此类型布局时,建议配合Panel.lazyRender属性使用,从而获得更好的性能.
		 * 因为Grid布局依赖于大量的计算,目前的算法性能与子元素数量是成倍数关系的. </br>
		 * 当通过Panel.add方法逐一添加1000个Shape到Panel中时,使用lazyRender的渲染时
		 * 间低于30ms,不使用的情况下,渲染时间高于2500ms. (渲染时间包含添加子元素的过程)
		 */		
		public static const GRID:String = "grid";
		/**
		 * 布局方式,横向 
		 */		
		public static const HORIZONTAL:String = "horizontal";
		/**
		 * 布局方式,纵向 
		 */		
		public static const VERTICAL:String = "vertical";
		/**
		 * 无布局 
		 */		
		public static const NONE:String = "none";
		
		/**
		 * 默认布局,也就是不做布局 
		 */		
		public static const ALIGH_NONE:String = "none";
		/**
		 * 居中排列 
		 */		
		public static const ALIGN_CENTER:String = "center";
		/**
		 * 居左(横向)或者居顶(纵向)排列 
		 */		
		public static const ALIGN_FIRST:String = "first";
		/**
		 * 居右(横向)或者居底(纵向)排列 
		 */		
		public static const ALIGN_LAST:String = "last";
		
		/**
		 * 布局类型,预定义在顶部 
		 */		
		public var type:String = HORIZONTAL;
		
		/**
		 * 目前只有FIRST和CENTER能生效 
		 */		
		public var align:String = ALIGH_NONE;
		
		/**
		 * 横向的间隔,不包括两侧 
		 */		
		public var hGap:int = 0;
		
		/**
		 * 纵向的间隔,不包括两头 
		 */		
		public var vGap:int = 0;
		
		/**
		 * Grid布局时,横向分隔的数目.
		 * 
		 * 仅设置column时,row会根据子元素数目变化.
		 * 
		 * 同时设置column和row的话,将会限制可以显示的元素最大
		 * 数目为column * row个.实际显示的最大数目,会因为高
		 * 宽的限制而有变化. 
		 */		
		public var column:int = 0;
		
		/**
		 * 当type为Grid时,设置此属性将会起到动态grid布局的效果(需要设置高宽).
		 * 假设当前有10个子元素,每个高宽为10,maxColumn设置为5.
		 * 如果宽度为40,那么实际的column就是4,而row是3(两行是满的,最后一行只有
		 * 一个对象) 
		 */		
		public var maxColumn:int = 0;
		
		/**
		 * Grid布局时,纵向分隔的数目.
		 * 
		 * 仅设置row时,column会根据子元素数目变化.
		 * 
		 * 同时设置column和row的话,将会限制可以显示的元素最大
		 * 数目为column * row个.实际显示的最大数目,会因为高
		 * 宽的限制而有变化. 
		 */		
		public var row:int = 0;
		
		public var maxRow:int = 0;
		
		/**
		 * padding是四边的间隔,可以单独设置,也可以设置padding来覆盖未设置的边.
		 * 可以通过设置padding=2来实现left,right,top,bottom都=2. 
		 */		
		public var padding:int = 0;
		public var paddingLeft:int = 0;
		public var paddingRight:int = 0;
		public var paddingTop:int = 0;
		public var paddingBottom:int = 0;

	    public var elms:Array = null;
		public var root:DisplayObject = null;
		protected var _autoGap:Boolean = false;
	    protected var _w:int = 0;
		protected var _wDirty:Boolean = false;
		protected var _h:int = 0;
		protected var _hDirty:Boolean = false;
		protected var _rendered:Function = null;
		/**
		 * 此属性目前为包内可用.
		 * 当Panel中需要大量更新显示对象的时候,通过提前设置此属性为true来阻止布局
		 * 每次添加或删除都更新,如果Panel中更新完毕,再次设置此属性为false,并显式
		 * 的调用updateDisplay方法来重新布局 
		 */		
		internal var _lazyRender:Boolean = false;
		
		/**
		 * 构造方法.
		 *  
		 * @param rendered 更新完布局后的回调方法,Panel控件会依赖此回调来更新高度和宽度
		 */		
		public function Layout(rendered:Function = null, root:DisplayObject = null) {
			elms = [];
			_rendered = rendered;
			if (root) {
				this.root = root;
				if (!this.root.stage) {
					this.root.addEventListener(Event.ADDED_TO_STAGE, onRootAddedToStage);
				}
			}
		}

		protected function onRootAddedToStage(e:Event):void {
			if (root) root.removeEventListener(Event.ADDED_TO_STAGE, onRootAddedToStage);
			if (autoGap) {
				_lazyRender = false;
				updateDisplay();
			}
		}

		/**
		 * 会有这种情况，当你生成一个layout的时候并不能完全确定它的gap固定应该是多少：
		 * 比如有一个可变长度的Label和另外一个固定长度Label在同一个layout里。
		 * 这时候可能想让两个Label把容器撑得尽量大（需要被上层容器的大小限制），从而
		 * 自动动态的计算固定长度Label的位置，来保证该Layou输出的高度或者宽度是能支持
		 * 的最大值，这个时候，可以使用该属性实现这个功能。
		 *
		 * 当设置此属性为true时，layout会自动根据当前width/height（需要主动设定）或者
		 * 父容器的width/height（未主动设定当前高宽时），计算容器中剩余的空间，并平均
		 * 分配到各个子对象的两侧。
		 *
		 * 一般情况下，这个属性最适用于两个对象被同时添加到HORIZONTAL或者VERTICAL布局当中。
		 * */
		public function set autoGap(value:Boolean):void {
			_autoGap = value;
		}

		public function get autoGap():Boolean {
			return _autoGap;
		}
	
		public function set width(value:int):void {
			_w = value;
			_wDirty = true;
		}
		
		public function get wDirty():Boolean {
			return _wDirty;
		}
		
	    public function get width():int {
	        return _w;
	    }
		
		public function set height(value:int):void {
			_h = value;
			_hDirty = true;
		}
		
		public function get hDirty():Boolean {
			return _hDirty;
		}
		
	    public function get height():int {
	        return _h;
	    }
	
	    public function addElms(value:Array):void {
			// 启动延迟更新布局
			_lazyRender = true;
			for each (var d:DisplayObject in value) {
				add(d);
			}
			_lazyRender = false;
	        updateDisplay();
	    }
		
		public function removeElms(value:Array):void {
			_lazyRender = true;
			for each (var d:DisplayObject in value) {
				remove(d);
			}
			_lazyRender = false;
			updateDisplay();
		}
		
	    public function add(elm:DisplayObject):void {
	        var i:int = elms.indexOf(elm);
			// 假如队列里已经有该元素,说明是要把它放到最后的位置
			// 所以需要更新该元素的index,并且重新计算布局
	        if (i != -1)
	            elms.splice(i, 1);
	        elms.push(elm);
	        updateDisplay();
	    }
		
		public function remove(elm:DisplayObject):void {
			var i:int = elms.indexOf(elm);
			if (i != -1) {
				elms.splice(i, 1);
				updateDisplay();
			}
		}
		
		/**
		 * 更新布局方法,当需要的时候可以调用. 
		 * Layout本身会在添加或删除对象的时候调用此方法进行更新.
		 * 外部如果需要强制重新更新布局的话,需要直接调用.
		 * 
		 * 此方法会被_lazyRender属性所阻断,如果设置_lazyRender为true时,调用此方法将会失效.
		 * 这个功能主要是为了优化性能而设置的.比如有一个控件需要同时添加或删除大量对象时,在更新之前,将
		 * layout的_lazyRender属性设置为true,当控件添加或删除对象完成之后,再将_lazyRender属性
		 * 设置为false,并显式调用此方法,就可以避免中间多次更新布局. 
		 */		
	    public function updateDisplay():void {
			if (_lazyRender) return;
			
			var p:TwoD = null, 
				layout:Function = null, 
				align:Function = null;
			
			switch (type) {
				case GRID : 
					layout = GridLayout.layout;
					align = GridLayout.align;
					break;
				case VERTICAL : 
					layout = VerticalLayout.layout;
					align = VerticalLayout.align;
					break;
				case HORIZONTAL : 
					layout = HorizontalLayout.layout;
					align = HorizontalLayout.align;
					break;
				case NONE : 
					layout = NoneLayout.layout;
					align = NoneLayout.align;
					break;
			}
			
			p = layout.apply(this, [this]);
			if (!_wDirty)
				_w = p.width;
			if (!_hDirty) 
				_h = p.height;
			align.apply(this, [this]);
			
			if (_rendered != null) _rendered.apply();
	    }
		
	}
}