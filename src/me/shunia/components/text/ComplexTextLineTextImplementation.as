/**
 * @DATE 2016/3/9;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {
	
	public class ComplexTextLineTextImplementation implements IComplexTextLineText {

		protected var content:String = "";
		protected var link:String = null;
		protected var linkHandler:Function = null;
		protected var fontFamily:String = null;
		protected var fontSize:int = 12;
		protected var fontColor:uint = 0;
		protected var fontBold:Boolean = false;
		protected var fontItalic:Boolean = false;
		protected var underLine:Boolean = false;
		protected var underLineColor:uint = 0xCCCCCC;

		public function setContent(value:String):IComplexTextLineText {
			content = value;
			return this;
		}

		public function setLink(value:String):IComplexTextLineText {
			link = value;
			return this;
		}

		public function setLinkHandler(value:Function):IComplexTextLineText {
			linkHandler = value;
			return this;
		}

		public function setFontFamily(value:String):IComplexTextLineText {
			fontFamily = value;
			return this;
		}

		public function setFontSize(value:int):IComplexTextLineText {
			fontSize = value;
			return this;
		}

		public function setFontColor(value:uint):IComplexTextLineText {
			fontColor = value;
			return this;
		}

		public function setFontBold(value:Boolean):IComplexTextLineText {
			fontBold = value;
			return this;
		}

		public function setFontItalic(value:Boolean):IComplexTextLineText {
			fontItalic = value;
			return this;
		}

		public function setUnderLine(value:Boolean):IComplexTextLineText {
			underLine = value;
			return this;
		}

		public function setUnderLineColor(value:uint):IComplexTextLineText {
			underLineColor = value;
			return this;
		}

		public function getContent():String {
			return content;
		}

		public function getLink():String {
			return link;
		}

		public function getLinkHandler():Function {
			return linkHandler;
		}

		public function getFontFamily():String {
			return fontFamily;
		}

		public function getFontSize():int {
			return fontSize;
		}

		public function getFontColor():uint {
			return fontColor;
		}

		public function getFontBold():Boolean {
			return fontBold;
		}

		public function getFontItalic():Boolean {
			return fontItalic;
		}

		public function getUnderLine():Boolean {
			return underLine;
		}

		public function getUnderLineColor():uint {
			return underLineColor;
		}
	}
	
}
