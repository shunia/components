/**
 * @DATE 2016/2/16;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.visual {

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import me.shunia.components.CompEvents;

	import me.shunia.components.interfaces.IItemRenderHolder;

	import me.shunia.components.interfaces.IItemRender;
	
	public class ItemRenderInteractiveHandler {

		protected var _target:IItemRenderHolder = null;
		protected var _item:IItemRender = null;
		protected var _p:Point = new Point();

		protected var _onItemClickCb:Function = null;
		protected var _onItemOverCb:Function = null;
		protected var _onItemOutCb:Function = null;
		protected var _onItemRenderCb:Function = null;

		public function ItemRenderInteractiveHandler(target:IItemRenderHolder) {
			if (possibleToTakeFutherAction(target)) {
				_target = target;

				if (component.stage) {
					onTargetAddedToStage(null);
				} else {
					component.addEventListener(Event.ADDED_TO_STAGE, onTargetAddedToStage);
				}
			}
		}

		protected function possibleToTakeFutherAction(target:IItemRenderHolder):Boolean {
			return target is DisplayObjectContainer;
		}

		protected function get component():DisplayObjectContainer {
			return _target ? _target as DisplayObjectContainer : null;
		}

		public function get item():IItemRender {
			return _item;
		}

		public function set onItemClickCallback(value:Function):void {
			_onItemClickCb = value;
		}

		public function set onItemOverCallback(value:Function):void {
			_onItemOverCb = value;
		}

		public function set onItemOutCallback(value:Function):void {
			_onItemOutCb = value;
		}

		public function set onItemRenderCallback(value:Function):void {
			_onItemRenderCb = value;
		}

		public function dispose():void {
			if (component) {
				component.removeEventListener(Event.ADDED_TO_STAGE, onTargetAddedToStage);
				component.removeEventListener(Event.REMOVED_FROM_STAGE, onTargetAddedToStage);
				component.removeEventListener(Event.ADDED_TO_STAGE, onTargetAddedToStage);
				component.removeEventListener(Event.ADDED_TO_STAGE, onTargetAddedToStage);
			}
			_target = null;
			_item = null;
			_p = null;

			_onItemClickCb = null;
			_onItemOutCb = null;
			_onItemOverCb = null;
			_onItemRenderCb = null;
		}

		protected function onTargetAddedToStage(e:Event):void {
			component.removeEventListener(Event.ADDED_TO_STAGE, onTargetAddedToStage);
			component.addEventListener(Event.REMOVED_FROM_STAGE, onTargetRemovedFromStage);
			
			component.addEventListener(MouseEvent.CLICK, onTargetClicked);
			component.addEventListener(MouseEvent.ROLL_OVER, onTargetOver);
			component.addEventListener(MouseEvent.ROLL_OUT, onTargetOut);
		}

		protected function onTargetRemovedFromStage(e:Event):void {
			component.removeEventListener(Event.REMOVED_FROM_STAGE, onTargetRemovedFromStage);
			component.addEventListener(Event.ADDED_TO_STAGE, onTargetAddedToStage);

			component.removeEventListener(MouseEvent.CLICK, onTargetClicked);
			component.removeEventListener(MouseEvent.ROLL_OVER, onTargetOver);
			component.removeEventListener(MouseEvent.ROLL_OUT, onTargetOut);
		}
		
		protected function onTargetClicked(e:MouseEvent):void {
			if (_item) {
				if (_onItemClickCb != null) {
					_onItemClickCb.apply(_target, [_item]);
				}
				var ce:CompEvents = new CompEvents(CompEvents.ITEM_CLICK, true);
				ce.params = [_item];
				component.dispatchEvent(ce);
			}
		}

		protected function onTargetOver(e:MouseEvent):void {
			component.addEventListener(MouseEvent.MOUSE_MOVE, onTargetMove)
			// 先行检测一次
			onTargetMove(e);
		}

		protected function onTargetOut(e:MouseEvent):void {
			onItemOut(_item);
			_item = null;
			component.removeEventListener(MouseEvent.MOUSE_MOVE, onTargetMove);
		}

		protected function onTargetMove(e:MouseEvent):void {
			_p.x = e.stageX;
			_p.y = e.stageY;
			var item:Array = component.stage ? component.stage.getObjectsUnderPoint(_p) : null;
			if (item && item.length) {
				var d:IItemRender = null,
					tmp:IItemRender = null;
				for (var i:int = 0; i < item.length; i ++) {
					if (item[i] is IItemRender && item[i] is _target.itemRenderer) {
						tmp = item[i] as IItemRender;
						if (component.contains(tmp as DisplayObject)) {
							d = tmp;
							break;
						}
					}
				}
				if (d) {
					if (_item != d)
						onItemOut(_item);
					onItemOver(d);
					_item = d;
				} else {
					onItemOut(_item);
					_item = null;
				}
			}
		}

		protected function onItemOut(item:IItemRender):void {
			if (item) {
				item.onMouseOut();
				var e:CompEvents = new CompEvents(CompEvents.ITEM_OUT, true);
				e.params = [item];
				component.dispatchEvent(e);
			}
		}

		protected function onItemOver(item:IItemRender):void {
			if (item) {
				item.onMouseOver();
				var e:CompEvents = new CompEvents(CompEvents.ITEM_OVER, true);
				e.params = [item];
				component.dispatchEvent(e);
			}
		}

	}
	
}
