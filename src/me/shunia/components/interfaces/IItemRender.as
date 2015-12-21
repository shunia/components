package me.shunia.components.interfaces
{
	public interface IItemRender
	{
		function set data(value:*):void;
		function get data():*;
		function onMouseOver():void;
		function onMouseOut():void;
		function onMouseClick():void;
		
		function onRerender(callback:Function):void;
	}
}