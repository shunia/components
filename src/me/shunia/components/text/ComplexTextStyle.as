/**
 * @DATE 2015/12/28;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {
	
	public class ComplexTextStyle {
		
		public var vertical:Boolean = true;
		public var rotation:String = "horizontal"; // horizontal / vertical
		public var width:int = 0;
		public var height:int = 0;
		
		public var renderTick:int = 0;
		
		public var paragraphIdentMeasurement:String = "space";
		public var paragraphIdent:int = 2;
		public var paragraphGap:int = 1;
		public var lineGap:int = 1;
		public var wordWrapIdentMeasureMent:String = "pixel";
		public var wordWrapIdent:int = 0;

		public var fontFamily:String = "微软雅黑,Arial";
		public var fontColor:uint = 0x000000;
		public var fontSize:int = 14;
		public var fontBold:Boolean = false;
		public var fontItalic:Boolean = false;
		
		public var graphicPreRenderSizeWidth:Number = fontSize;
		public var graphicPreRenderSizeHeight:Number = fontSize;

		public function copy(style:ComplexTextStyle):void {
			if (!(this is ComplexTextStyle)) return;

			style.vertical = vertical;
			style.rotation = rotation;
			style.width = width;
			style.height = height;
			style.renderTick = renderTick;
			style.paragraphIdentMeasurement = paragraphIdentMeasurement;
			style.paragraphIdent = paragraphIdent;
			style.paragraphGap = paragraphGap;
			style.lineGap = lineGap;
			style.wordWrapIdentMeasureMent = wordWrapIdentMeasureMent;
			style.wordWrapIdent = wordWrapIdent;
			style.fontFamily = fontFamily;
			style.fontColor = fontColor;
			style.fontSize = fontSize;
			style.fontBold = fontBold;
			style.fontItalic = fontItalic;
		}

	}
	
}
