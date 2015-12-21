package me.shunia.components
{

	import flash.events.Event;

	/**
	 * 控件事件类.
	 * 
	 * 需要交互的控件,在触发交互事件时应派发此类中的事件.
	 *  
	 * @author qingfenghuang
	 */	
	public class CompEvents extends Event
	{
		
		public static const ITEM_CHANGE:String = "itemChange";
		public static const CHANGE:String = "change";
		public static const ITEM_CLICK:String = "itemClick";
		
		/**
		 * 事件中附加的参数.全部组合到这个数据里. 
		 */		
		public var params:Array= null;
		
		public function CompEvents(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
	}
}