/**
 * @DATE 2015/12/25;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {
	
	public interface IComplexTextLineText extends IComplexTextLine {

		function setContent(value:String):IComplexTextLineText;

		function setLink(value:String):IComplexTextLineText;

		function setLinkHandler(value:Function):IComplexTextLineText;

		function setFontFamily(value:String):IComplexTextLineText;

		function setFontSize(value:int):IComplexTextLineText;

		function setFontColor(value:uint):IComplexTextLineText;

		function setFontBold(value:Boolean):IComplexTextLineText;

		function setFontItalic(value:Boolean):IComplexTextLineText;

		function setUnderLine(value:Boolean):IComplexTextLineText;

		function setUnderLineColor(value:uint):IComplexTextLineText;

	}
	
}
