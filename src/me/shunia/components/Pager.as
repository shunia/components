package me.shunia.components
{

	import flash.display.DisplayObject;

	import me.shunia.components.interfaces.IItemRenderHolder;
	import me.shunia.components.interfaces.IItemRender;
	import me.shunia.components.utils.PropConfig;

	/**
	 * 不负责按钮的创建,但是可以负责中间子控件的创建,类似于list.
	 * 也可以不负责创建,通过事件只提供数据.
	 *  
	 * @author qingfenghuang
	 */	
	public class Pager extends Panel implements IItemRenderHolder
	{
		
		/**
		 * 如果需要渲染子项,提供IItemRender接口的实现类的定义 
		 */		
		public static const P_CONTENT_RENDER:String = "contentRender";
		/**
		 * 单页数量,pager控件会每次都初始化出同等此数目的子项,所以ItemRender一定要支持设置空数据 
		 */		
		public static const P_PAGE_SIZE:String = "pageSize";
		/**
		 * 是否允许循环翻页 
		 */		
		public static const P_ALLOW_CYCLE_UPDATE:String = "allowCycleUpdate";
		public static const P_DIRECTION:String = "direction";
		public static const P_ALIGN:String = "align";
		public static const P_GAP:String = "gap";
		public static const P_CONTENT_BG:String = "contentBg";
		public static const P_CONTENT_WIDTH:String = "contentWidth";
		public static const P_CONTENT_HEIGHT:String = "contentHeight";
		public static const P_LEFT_OR_TOP_BTN:String = "leftOrTopBtn";
		public static const P_RIGHT_OR_BOTTOM_BTN:String = "rightOrBottomBtn";
		public static const P_DATA:String = "data";
		public static const P_ALLOW_EMPTY_DATA:String = "allowEmptyData";
		
		/**
		 * 临时缓存池,用来循环利用之前生成的控件 
		 */		
		protected var _pool:Array = null;
		
		protected var _wrapper:DataList = null;
		protected var _leftOrTopBtn:Button = null;
		protected var _rightOrBottomBtn:Button = null;
		protected var _props:PropConfig = null;
		protected var _contentRender:Class = null;
		protected var _currentPage:int = -1;
		protected var _pNum:int = 0;
		protected var _pMax:int = 0;
		protected var _size:int = 0;
		protected var _data:Array = null;
		protected var _allowCycleUpdate:Boolean = false;
		protected var _allowEmptyData:Boolean = true;
		
		public function Pager()
		{
			super();
			_pool = [];
			_wrapper = new DataList();
			_props = new PropConfig();
		}
		
		public function set data(value:Array):void {
			if (value != _data) {
				_data = value;
				_currentPage = -1;
				update();
			}
		}
		
		public function get data():Array {
			return _data;
		}
		
		public function set itemRenderer(value:Class):void {
			if (_contentRender != value) {
				_contentRender = value;
				// 清空之前的缓存,因为没用了
				_pool = [];
				update();
			}
		}

		public function get itemRenderer():Class {
			return _contentRender;
		}
		
		public function get totalPage():int {
			return _pNum;
		}

		public function get currentPage():int {
			return _currentPage;
		}

		public function set currentPage(value:int):void {
			_currentPage = value;
			if (_currentPage > _pNum) _currentPage = _pNum;
			else if (_currentPage < 0) _currentPage = 0;
		}

		public function setProp(k:String, v:*):Pager {
			_props.setProp(k, v);
			return this;
		}
		
		public function update():Pager {
			updateStyle();
			updateProps();
			updateView();
			calculateAndApply();
			return this;
		}
		
		protected function updateStyle():void {
			if (_props.hasProp(P_DIRECTION)) {
				var d:String = _props.safeProp(P_DIRECTION, layout.type);
				layout.type = _wrapper.layout.type = d;
			}
			if (_props.hasProp(P_ALIGN)) {
				var a:String = _props.safeProp(P_ALIGN, layout.align);
				layout.align = _wrapper.layout.align = a;
			}
			if (_props.hasProp(P_GAP)) {
				var g:int = 0;
				if (layout.type == Layout.VERTICAL) {
					g = _props.safeProp(P_GAP, layout.vGap);
					layout.vGap = g;
				} else {
					g = _props.safeProp(P_GAP, layout.hGap);
					layout.hGap = g;
				}
			}
			if (_props.hasProp(P_CONTENT_BG)) 
				_wrapper.background = _props.safeProp(P_CONTENT_BG, null);
			if (_props.hasProp(P_CONTENT_WIDTH)) 
				_wrapper.width = _props.safeProp(P_CONTENT_WIDTH, 0);
			if (_props.hasProp(P_CONTENT_HEIGHT)) 
				_wrapper.height = _props.safeProp(P_CONTENT_HEIGHT, 0);
		}
		
		protected function updateProps():void {
			if (_props.hasProp(P_ALLOW_CYCLE_UPDATE)) 
				_allowCycleUpdate = _props.safeProp(P_ALLOW_CYCLE_UPDATE, _allowCycleUpdate);
			if (_props.hasProp(P_ALLOW_EMPTY_DATA)) 
				_allowEmptyData = _props.safeProp(P_ALLOW_EMPTY_DATA, _allowEmptyData);
			if (_props.hasProp(P_PAGE_SIZE)) 
				_pMax = _props.safeProp(P_PAGE_SIZE, null);
			if (_props.hasProp(P_CONTENT_RENDER)) {
				var cls:Class = _props.safeProp(P_CONTENT_RENDER, _contentRender);
				if (_contentRender != cls) 
					// 清空之前的缓存,因为没用了
					_contentRender = cls;
					_pool = [];
			}
			if (_props.hasProp(P_DATA)) {
				_data = _props.safeProp(P_DATA, null);
				_currentPage = -1;
			}
			// 拿出长度当作最大尺寸
			_size = _data ? _data.length : 0;
		}
		
		protected function updateView():void {
			if (_props.hasProp(P_LEFT_OR_TOP_BTN)) 
				_leftOrTopBtn = _props.safeProp(P_LEFT_OR_TOP_BTN, null);
			if (_props.hasProp(P_RIGHT_OR_BOTTOM_BTN)) 
				_rightOrBottomBtn = _props.safeProp(P_RIGHT_OR_BOTTOM_BTN, null);
			// 清空再添加
			removeAll();
			// 添加
			if (_leftOrTopBtn && !contains(_leftOrTopBtn)) {
				_leftOrTopBtn.on(onPrevPage);
				add(_leftOrTopBtn);
			}
			if (_contentRender != null && _size) {
				releasePool();
				_wrapper.dispose();
				add(_wrapper);
			}
			if (_rightOrBottomBtn && !contains(_rightOrBottomBtn)) {
				_rightOrBottomBtn.on(onNextPage);
				add(_rightOrBottomBtn);
			}
		}
		
		/**
		 * 向左或者向上翻页 
		 */		
		protected function onPrevPage():void {
			flip(true);
		}
		
		/**
		 * 向右或者向下翻页 
		 */		
		protected function onNextPage():void {
			flip(false);
		}
		
		/**
		 * 调用此方法后,使用getItemsOfCurrentPage()方法获取当前应该展示的数据 
		 */		
		public function flip(isPrev:Boolean):void {
			if (flipPage(isPrev)) 
				render();
			// 更新按钮状态,边界状态需要更新按钮的点击与否
			updateBtnStatus();
		}
		
		/**
		 * 重新渲染 
		 */		
		protected function render():void {
			releasePool();
			_wrapper.dispose();
			_wrapper.itemRenderer = _contentRender;
			_wrapper.data = getItemsOfCurrentPage(),
			layout.updateDisplay();
		}
		
		/**
		 * 计算和更新 
		 */		
		protected function calculateAndApply():void {
			// 没有size白搭
			if (!_size) return;
			// 算出页数
			_pNum = Math.ceil(_size / _pMax);
			// 更新子项
			if (_contentRender != null) {
				onNextPage();
			}
		}
		
		/**
		 * 当前应该展示的数据,可能包含空相,因为默认行为会用空数据填充没有铺满一次翻页的数据.
		 * 用 P_ALLOW_EMPTY_DATA 来改变这一默认行为.
		 *  
		 * @return 
		 */		
		public function getItemsOfCurrentPage():Array {
			var r:Array = [], 
				n:int = itemCountCurrentPage, 
				i:int = 0;
			
			// 在范围内的数据正常返回,小于范围时用null填充,就是因为这里,所以需要注意,itemrender一定要支持空数据渲染
			// 要么就干脆不要提供itemrender,自己渲染,只是拿pager控件返回的数据
			while (i < _pMax) {
				if (i < n) {
					r.push(_data[_currentPage * _pMax + i]);
				} else if (_allowEmptyData) {
					r.push(null);
				}
				i ++;
			}
			
			return r;
		}
		
		/**
		 * 当前页可以展示的数量 
		 * @return 
		 */		
		public function get itemCountCurrentPage():int {
			var n:int = 0;
			if (isFirstPage) {
				n = _pNum ? _pMax : _size % _pMax;
			} else if (isLastPage) {
				n = _size % _pMax;
			} else {
				n = _pMax;
			}
			return n;
		}
		
		/**
		 * 处理翻页逻辑
		 *  
		 * @param isPrev
		 */		
		protected function flipPage(isPrev:Boolean):Boolean {
			var p:int = _currentPage, 
				changed:Boolean = false;
			if (isPrev) 
				p = p == 0 ? 
						(_allowCycleUpdate ? 
							lastPage : 
							firstPage) : 
						p - 1;
			else 
				p = p == lastPage ? 
						(_allowCycleUpdate ? 
							firstPage : 
							lastPage) : 
						p + 1;
			
			changed = (p != _currentPage);
			_currentPage = p;
			return changed;
		}
		
		/**
		 * 当前页是否第一页 
		 * @return 
		 */		
		protected function get isFirstPage():Boolean {
			return _currentPage == firstPage;
		}
		
		/**
		 * 判断当前页是否最后一页 
		 * @return 
		 */		
		protected function get isLastPage():Boolean {
			return _currentPage == lastPage;
		}
		
		/**
		 * 第一页的页数,因为页数从0开始,所以第一页是0 
		 * @return 
		 */		
		protected function get firstPage():int {
			return 0;
		}
		
		/**
		 * 最后一页的页数 
		 * @return 
		 */		
		protected function get lastPage():int {
			return _pNum ? _pNum - 1 : 0;
		}
		
		/**
		 * 更新左右侧按钮状态 
		 */		
		protected function updateBtnStatus():void {
			var leftEnabled:Boolean = isFirstPage && !_allowCycleUpdate ? false : _pNum == 1 ? false : true;
			var rightEnabled:Boolean = isLastPage && !_allowCycleUpdate ? false : _pNum == 1 ? false : true;
			if (_leftOrTopBtn) _leftOrTopBtn.enabled = leftEnabled;
			if (_rightOrBottomBtn) _rightOrBottomBtn.enabled = rightEnabled;
		}
		
		/**
		 * 创建Item. 
		 * @param data
		 * @return 
		 */		
		protected function createItem(data:*):DisplayObject {
			if (_contentRender == null) return null;
			
			var i:IItemRender = _pool.length ? 
				_pool.shift() as IItemRender : 
				new _contentRender();
			i.data = data;
			return i as DisplayObject;
			return null;
		}
		
		/**
		 *释放临时缓存的控件 
		 */		
		protected function releasePool():void {
			var len:int = _wrapper.elements.length;
			if (len) {
				var elm:IItemRender = null;
				for (var i:int = 0; i < len; i ++) {
					elm = _wrapper.elements[i] as IItemRender;
					if (elm && _pool.indexOf(elm) == -1) 
						_pool.push(elm);
				}
			}
		}
		
	}
}