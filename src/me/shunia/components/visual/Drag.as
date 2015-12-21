package me.shunia.components.visual
{

	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;

	/**
	 * 拖动辅助类,不限定于Sprite 
	 * 
	 * @author qingfenghuang
	 */	
	public class Drag
	{
		
		protected var _target:DisplayObject = null;
		protected var _orignalLockBound:Rectangle = null;
		protected var _lockBound:Rectangle = null;
		protected var _stage:Stage = null;
		protected var _parent:DisplayObject = null;
		protected var _cb:Function = null;
		protected var _isDown:Boolean = false;
		protected var _isOver:Boolean = false;
		protected var _ox:Number = 0;
		protected var _oy:Number = 0;
		protected var _isDragging:Boolean = false;
		
		public function Drag(target:DisplayObject = null, cb:Function = null, lockBound:Rectangle = null)
		{
			setUp(target, cb, lockBound);
		}
		
		public function get target():DisplayObject {
			return _target;
		}
		
		public function get isDragging():Boolean {
			return _isDragging;
		}
		
		public function setUp(target:DisplayObject, cb:Function, lockBound:Rectangle = null):void {
			_target = target;
			_cb = cb;
			_orignalLockBound = lockBound;
		}
		
		public function start():void {
			if (_target.stage && _target.parent) {
				postStart();
			} else {
				_target.addEventListener(Event.ADDED_TO_STAGE, postStart);
			}
		}
		
		protected function postStart(e:Event = null):void {
			_stage = _target.stage;
			_parent = _target.parent;
			_target.addEventListener(MouseEvent.ROLL_OVER, over);
		}
		
		protected function over(e:MouseEvent):void {
			_isOver = true;
			if (!_isDown) {
				_target.addEventListener(MouseEvent.MOUSE_DOWN, down);
				_target.addEventListener(MouseEvent.ROLL_OUT, out);
			}
			try {
				Mouse.cursor = "drag";
			} catch (e:Error) {
				trace("No supported mouse cursor [drag]!");
			}
		}
		
		protected function out(e:MouseEvent):void {
			_isOver = false;
			if (!_isDown) {
				Mouse.cursor = MouseCursor.AUTO;
				_target.removeEventListener(MouseEvent.MOUSE_DOWN, down);
				_stage.removeEventListener(MouseEvent.MOUSE_UP, up);
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);
			}
		}
		
		protected function down(e:MouseEvent):void {
			_isDown = true;
			_isDragging = false;
			
			if (!_orignalLockBound) _lockBound = _parent.getBounds(_parent);
			_ox = e.stageX;
			_oy = e.stageY;
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
			_stage.addEventListener(MouseEvent.MOUSE_UP, up);
			e.stopPropagation();
		}
		
		protected function move(e:MouseEvent):void {
//			e.stopPropagation();
			e.updateAfterEvent();
			
			_isDragging = true;
			
			var dx:int = e.stageX - _ox,
				dy:int = e.stageY - _oy;
			_ox = e.stageX;
			_oy = e.stageY;
			var p:Point = restrict(_target, dx, dy, _orignalLockBound ? _orignalLockBound : _lockBound);
			if (_cb != null) _cb(p.x, p.y);
		}
		
		protected function up(e:MouseEvent):void {
			_isDown = false;
			_isDragging = false;
			if (!_isOver) {
				Mouse.cursor = MouseCursor.AUTO;
				_target.removeEventListener(MouseEvent.MOUSE_DOWN, down);
			}
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, up);
		}
		
		public function stop():void {
			if (_target) {
				_target.removeEventListener(MouseEvent.ROLL_OVER, over);
				_target.removeEventListener(MouseEvent.MOUSE_DOWN, down);
				_target.removeEventListener(MouseEvent.ROLL_OUT, out);
			}
			if (_stage) {
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);
				_stage.removeEventListener(MouseEvent.MOUSE_UP, up);
			}
			
			_isDown = false;
		}
		
		public function dispose():void {
			stop();
			
			_isDown = false;
			_parent = null;
			_lockBound = null;
			_target = null;
			_stage = null;
			_cb = null;
		}
		
		/**
		 * 
		 * 计算target经过offset之后是否还在lockBound区域里,返回的是该次应该offset的x和y值.<br/>
		 * 当targetRect经过offset之后不会超出lockBound,那么返回的就是offsetX和offsetY.<br/>
		 * 否则返回的是让targetRect最靠近lockBound但是又不会超出的x和y值. <br/>
		 * <br/>
		 * 该方法会将计算出来的x和y位移应用到target对象上!如果不想应用位移,使用restrictRect方法. 
		 * <br/>
		 * @param target 要计算的显示对象
		 * @param offsetX 准备要在x轴上位移的距离
		 * @param offsetY 准备要在y轴上位移的距离
		 * @param lockBound 用来限制位移区域的矩形
		 * @return 最大移动幅度,只会小于等于offsetX和offsetY,不可能超过
		 */		
		public static function restrict(target:DisplayObject, offsetX:Number, offsetY:Number, lockBound:Rectangle = null):Point {
			if (!target.parent) return new Point();
			if (!lockBound && target.parent) lockBound = target.parent.getBounds(target.parent);
			var r:Rectangle = target.getBounds(target.parent);
			var point:Point = restrictRect(r, offsetX, offsetY, lockBound);
			target.x += point.x;
			target.y += point.y;
			return point;
		}
		
		/**
		 * 计算targetRect经过offset之后是否还在lockBound区域里,返回的是该次应该offset的x和y值.<br/>
		 * 当targetRect经过offset之后不会超出lockBound,那么返回的就是offsetX和offsetY.<br/>
		 * 否则返回的是让targetRect最靠近lockBound但是又不会超出的x和y值.
		 * <br/>
		 * @param targetRect 要计算的基础矩形
		 * @param offsetX 准备要在x轴上位移的距离
		 * @param offsetY 准备要在y轴上位移的距离
		 * @param lockBound 用来限制位移区域的矩形
		 * @return 最大移动幅度,只会小于等于offsetX和offsetY,不可能超过
		 */		
		public static function restrictRect(targetRect:Rectangle, offsetX:Number, offsetY:Number, lockBound:Rectangle):Point {
			var p:Point = new Point();
			targetRect.offset(offsetX, offsetY);
			var x:Number = offsetX, y:Number = offsetY;
			if (targetRect.left < lockBound.left) offsetX -= targetRect.left - lockBound.left;
			else if (targetRect.right > lockBound.right) offsetX -= targetRect.right - lockBound.right;
			if (targetRect.top < lockBound.top) offsetY -= targetRect.top - lockBound.top;
			else if (targetRect.bottom > lockBound.bottom) offsetY -= targetRect.bottom - lockBound.bottom;
			p.x = offsetX;
			p.y = offsetY;
			return p;
		}
		
	}
}