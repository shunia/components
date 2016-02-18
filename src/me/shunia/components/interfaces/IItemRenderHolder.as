package me.shunia.components.interfaces
{
	public interface IItemRenderHolder
	{
		
		function set data(value:Array):void;
		function get data():Array;
		
		function set itemRenderer(value:Class):void;
		function get itemRenderer():Class;
		
	}
}