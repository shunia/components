/**
 * @DATE 2015/12/28;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {

	import flash.display.DisplayObject;
	
	public interface IComplexTextLineGraphic extends IComplexTextLine {

		function setContent(value:DisplayObject):IComplexTextLineGraphic;

		function setLink(value:String):IComplexTextLineGraphic;

		function setLinkHandler(value:Function):IComplexTextLineGraphic;

		function setWidth(value:Number):IComplexTextLineGraphic;

		function setHeight(value:Number):IComplexTextLineGraphic;

		function getContent():DisplayObject;

		function getLink():String;

		function getLinkHandler():Function;

		function getWidth():Number;

		function getHeight():Number;

	}
	
}
