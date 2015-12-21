package me.shunia.components.visual
{

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	/**
	 * 需要初始化的时候设置一下父容器.
	 *  
	 * @author qingfenghuang
	 */	
	public class PopUp
	{
		
		/**
		 * PopUpItem管理类 
		 */		
		protected static var _manager:InternalPopupManager = null;
		
		/**
		 * 初始化方法,传入弹出层所在的父容器,模态状态下的背景色和透明度.
		 *  
		 * @param parent
		 * @param modalColor
		 * @param modalAlpha
		 */		
		public static function init(parent:DisplayObjectContainer, modalColor:uint = 0, modalAlpha:Number = 0.4):void {
			_manager = new InternalPopupManager();
			_manager.parent = parent;
			PopUpItem.modalColor = modalColor;
			PopUpItem.modalAlpha = modalAlpha;
		}
		
		public static function create(view:DisplayObject):int {
			return _manager.add(view);
		}
		
		public static function center(view:DisplayObject, modal:Boolean = true):int {
			var id:int = create(view);
			get(id).mode = PopUpItem.MODE_RELATIVE;
			get(id).center = true;
			get(id).modal = modal;
			pop(id);
			return id;
		}
		
		public static function to(view:DisplayObject, anchor:DisplayObject, offsetX:Number = 0, offsetY:Number = 0):int {
			var id:int = create(view);
			get(id).mode = PopUpItem.MODE_ANCHOR;
			get(id).anchor = anchor;
			get(id).offsetX = offsetX;
			get(id).offsetY = offsetY;
			pop(id);
			return id;
		}
		
		public static function pos(view:DisplayObject, position:Point, offsetX:Number = 0, offsetY:Number = 0):int {
			var id:int = create(view);
			get(id).mode = PopUpItem.MODE_ANCHOR;
			get(id).position = position;
			get(id).offsetX = offsetX;
			get(id).offsetY = offsetY;
			pop(id);
			return id;
		}
		
		public static function get(id:int):PopUpItem {
			return _manager.g(id);
		}
		
		public static function toggle(id:int):void {
			var item:PopUpItem = get(id);
			if (item) 
				item.isPoping ? dismiss(id) : pop(id);
		}
		
		public static function pop(id:int):void {
			var item:PopUpItem = get(id);
			if (item) {
				item.pop();
			}
		}
		
		public static function dismiss(id:int):void {
			var item:PopUpItem = get(id);
			if (item) 
				item.dismiss();
		}
		
		public static function dispose(id:int):void {
			var item:PopUpItem = get(id);
			if (item) {
				item.dispose();
				_manager.remove(item);
			}
		}
		
	}
}

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

class InternalPopupManager {
	
	protected static var _id:int = 0;
	
	internal var popsDict:Dictionary = new Dictionary();
	
	public var parent:DisplayObjectContainer = null;
	
	internal function g(id:int):PopUpItem {
		var item:PopUpItem = popsDict.hasOwnProperty(String(id)) ? popsDict[id] : null;
		return item;
	}
	
	internal function getByView(view:DisplayObject):PopUpItem {
		var item:PopUpItem = null;
		for (var id:* in popsDict) {
			if (popsDict[id].view == view) {
				item = popsDict[id];
				break;
			}
		}
		return item;
	}
	
	internal function add(view:DisplayObject):int {
		var item:PopUpItem = getByView(view);
		if (!item) {
			item = new PopUpItem();
			item.parent = parent;
			item.view = view;
			item.id = getId();
			popsDict[item.id] = item;
		}
		
		return item.id;
	}
	
	internal function remove(item:PopUpItem):void {
		if (item) removeById(item.id);
	}
	
	internal function removeById(id:int):void {
		if (g(id))
			delete popsDict[id];
	}
	
	protected function getId():int {
		return _id ++;
	}
	
}

class PopUpItem
{
	
	internal var view:DisplayObject = null;
	internal var parent:DisplayObjectContainer = null;
	internal var id:int = 0;
	
	/**
	 * 定点弹窗 
	 */		
	public static const MODE_ANCHOR:int = 1;
	/**
	 * 相对布局弹窗 
	 */		
	public static const MODE_RELATIVE:int = 2;
	/**
	 * 遮挡背景对象 
	 */		
	protected static var _modal:Sprite = null;
	/**
	 * 当前有模态的窗口的集合 
	 */	
	protected static var _modalItems:Array= [];
	/**
	 * 可设置项:遮挡背景颜色 
	 */		
	public static var modalColor:uint = 0;
	/**
	 * 可设置项:遮挡背景透明度 
	 */		
	public static var modalAlpha:Number = 0.4;
	
	/**
	 * 弹窗模式,包括定点:PopUpItem.MODE_ANCHOR和相对布局:PopUpItem.MODE_RELATIVE. 
	 */		
	public var mode:int = MODE_RELATIVE;
	/**
	 * 是否遮挡背景 
	 */		
	public var modal:Boolean = false;
	/**
	 * 点击view以外的区域是否自动移除view 
	 */		
	protected var _outsideClose:Boolean = false;
	public function set outsideClose(value:Boolean):void {
		if (value != _outsideClose) {
			_outsideClose = value;
			onOutsideCloseChange();
		}
	}
	public function get outsideClose():Boolean {
		return _outsideClose;
	}
	/**
	 * 锚点对象,用来指定弹出窗口相对该对象而弹出.默认会弹出在对象的(0,0)位置.</br>
	 * 仅在mode设置为PopUpItem.MODE_ANCHOR时生效.</br>
	 * 当生效时,设置该属性会覆盖已经设置过的position属性. 
	 */		
	public var anchor:DisplayObject = null;
	/**
	 * 锚点坐标在X轴上的偏移位置.</br>
	 * 仅在mode设置为PopUpItem.MODE_ANCHOR时生效.
	 */		
	public var offsetX:Number = 0;
	/**
	 * 锚点坐标在Y轴上的偏移位置.</br>
	 * 仅在mode设置为PopUpItem.MODE_ANCHOR时生效.
	 */		
	public var offsetY:Number = 0;
	/**
	 * 锚点位置,用来指定弹出窗口相对该位置而弹出.当设置anchor时,该属性会被覆盖.</br>
	 * 仅在mode设置为PopUpItem.MODE_ANCHOR时生效.</br>
	 * 设置该属性会覆盖已经设置过的anchorPoint属性. 
	 */		
	public var position:Point = new Point();
	/**
	 * MODE_RELATIVE模式下用来方便的定位居中. 
	 */		
	public var center:Boolean = false;
	/**
	 * 当前是否正在弹出状态
	 *  
	 * @return 
	 */	
	public function get isPoping():Boolean {
		return view && view.parent;
	}
	
	/**
	 * 重新计算位置信息并弹出 
	 */	
	internal function pop():void {
		updatePosition();
		updateModal();
		if (parent && !parent.contains(view)) {
			onOutsideCloseChange();
			parent.addChild(view);
		}
	}
	
	protected function onOutsideCloseChange():void {
		if (outsideClose) {
			if (!stage) 
				view.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			else 
				onAdded(null);
		} else {
			if (view.hasEventListener(Event.ADDED_TO_STAGE)) 
				view.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
	}
	
	/**
	 * 关闭弹出窗 
	 */	
	internal function dismiss():void {
		if (parent.contains(view)) {
			view.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			parent.removeChild(view);
		}
		if (modal && parent.contains(_modal)) 
			parent.removeChild(_modal);
		
		if (stage) stage.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	/**
	 * 销毁弹出窗,销毁之前会尝试关闭
	 */	
	internal function dispose():void {
		dismiss();
		anchor = null;
		view = null;
		parent = null;
	}
	
	/**
	 * 监听添加到舞台事件,然后才开始监听舞台的点击事件
	 * 这里延迟一帧再监听舞台的点击事件,是为了处理事件流导致
	 * 点击弹出的同时监听在外部点击的事件的话,外部点击事件会
	 * 立刻触发一次,从而导致根本打不开弹出框
	 *  
	 * @param event
	 */		
	protected function onAdded(event:Event):void {
		if (stage && outsideClose) 
			stage.addEventListener(Event.ENTER_FRAME, onNextFrame);
	}
	
	protected function onNextFrame(event:Event):void {
		stage.removeEventListener(Event.ENTER_FRAME, onNextFrame);
		postUpdate();
	}
	
	protected function postUpdate():void {
		stage.addEventListener(Event.RESIZE, onResize);
		if (mode == MODE_ANCHOR && (anchor || position)) 
			stage.addEventListener(Event.ENTER_FRAME, onListenForMovement);
		if (stage && outsideClose) 
			stage.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	protected function onResize(event:Event):void {
		updatePosition();
		updateModal();
	}
	
	protected function onListenForMovement(event:Event):void {
		updatePosition();
	}
	
	protected function onClick(e:MouseEvent):void {
		var viewRect:Rectangle = view.getBounds(stage), 
			inside:Boolean = viewRect.contains(e.stageX, e.stageY);
		if (!inside) dismiss();
	}
	
	/**
	 * 计算位置 
	 */	
	protected function updatePosition():void {
		if (mode == MODE_ANCHOR) {
			if (anchor) {
				// 计算成全局坐标
				position = anchor.parent ? anchor.parent.localToGlobal(new Point(anchor.x, anchor.y)) : new Point();
				// 如果弹出层不是舞台的话,需要再从全局左边计算成弹出层的坐标
				if (!(parent is Stage)) position = parent.globalToLocal(position);
			}
			
			view.x = position.x + offsetX;
			view.y = position.y + offsetY;
		} else {
			if (center) {
				view.x = parent is Stage ? 
					(stage.stageWidth - view.width) / 2 : 
					(parent.width - view.width) / 2;
				view.y = parent is Stage ? 
					(stage.stageHeight - view.height) / 2 : 
					(parent.height - view.height) / 2;
			} else {
				view.x = position.x + offsetX;
				view.y = position.y + offsetY;
			}
		}
	}
	
	/**
	 * 更新模态窗口 
	 */	
	protected function updateModal():void {
		if (!modal) {
			_modal = new Sprite();
			_modal.mouseEnabled = _modal.mouseChildren = false;
			_modal.graphics.beginFill(modalColor, modalAlpha);
			_modal.graphics.drawRect(0, 0, 10, 10);
			_modal.graphics.endFill();
		}
		if (modal) {
			if (!parent.contains(_modal)) parent.addChild(_modal);
		} else {
			
		}
		if (modal && !parent.contains(_modal)) {
			parent.addChild(_modal);
			_modalItems.push(this);
		} else if (!modal && parent.contains(_modal)) {
			_modalItems.splice(_modalItems.indexOf(this), 1);
			if (_modalItems.length == 0) 
				parent.removeChild(_modal);
		}
		
		if (parent.contains(_modal)) {
			_modal.width = stage ? stage.stageWidth : parent.width;
			_modal.height = stage ? stage.stageHeight : parent.height;
		}
	}
	
	/**
	 * 获取舞台
	 *  
	 * @return 
	 */	
	protected function get stage():Stage {
		return parent && parent.stage ? parent.stage : null;
	}
	
}