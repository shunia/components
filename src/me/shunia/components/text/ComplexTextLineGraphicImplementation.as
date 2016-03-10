/**
 * @DATE 2016/3/9;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {

	import flash.display.DisplayObject;
	
	public class ComplexTextLineGraphicImplementation implements IComplexTextLineGraphic {

		protected var content:DisplayObject = null;
		protected var link:String = null;
		protected var linkHandler:Function = null;
		protected var width:Number = 0;
		protected var height:Number = 0;

		public function setContent(value:DisplayObject):IComplexTextLineGraphic {
			content = value;
			width = content.width;
			height = content.height;
			return this;
		}

		public function setLink(value:String):IComplexTextLineGraphic {
			link = value;
			return this;
		}

		public function setLinkHandler(value:Function):IComplexTextLineGraphic {
			linkHandler = value;
			return this;
		}

		public function setWidth(value:Number):IComplexTextLineGraphic {
			width = value;
			return this;
		}

		public function setHeight(value:Number):IComplexTextLineGraphic {
			height = value;
			return this;
		}

		public function getContent():DisplayObject {
			return content;
		}

		public function getLink():String {
			return link;
		}

		public function getLinkHandler():Function {
			return linkHandler;
		}

		public function getWidth():Number {
			return width;
		}

		public function getHeight():Number {
			return height;
		}
	}
	
}
