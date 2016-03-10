/**
 * @DATE 2015/12/28;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {

	import flash.utils.describeType;
	
	public class ComplexTextStyle {

		/*
		* 为了支持underline等,这是必须的最低间隔,它会被附加到所有的
		* 行间距上
		* */
		internal static const DEFAULT_GAP:int = 2;

		public var vertical:Boolean = true;
		public var rotation:String = "horizontal"; // horizontal / vertical
		public var width:int = 100;
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

		public var underLineForLink:Boolean = true;
		public var underLineThickness:int = 1;
		public var underLineColor:uint = 0xFF0000;
		
		public var graphicPreRenderSizeWidth:Number = fontSize;
		public var graphicPreRenderSizeHeight:Number = fontSize;

		private var _keys:Array = [];

		public function copyTo(style:ComplexTextStyle):void {
			if (!(this is ComplexTextStyle)) return;

			if (_keys.length == 0) {
				var xml:XML = describeType(this);
				for each (var v:XML in xml.variable) {
					_keys.push(v.@name);
				}
			}
			for each (var k:String in _keys) {
				style[k] = this[k];
			}

//			style.vertical = vertical;
//			style.rotation = rotation;
//			style.width = width;
//			style.height = height;
//			style.renderTick = renderTick;
//			style.paragraphIdentMeasurement = paragraphIdentMeasurement;
//			style.paragraphIdent = paragraphIdent;
//			style.paragraphGap = paragraphGap;
//			style.lineGap = lineGap;
//			style.wordWrapIdentMeasureMent = wordWrapIdentMeasureMent;
//			style.wordWrapIdent = wordWrapIdent;
//			style.fontFamily = fontFamily;
//			style.fontColor = fontColor;
//			style.fontSize = fontSize;
//			style.fontBold = fontBold;
//			style.fontItalic = fontItalic;
//
//			style.underLineForLink = underLineForLink;
//			style.underLineColor = underLineColor;
//
//			style.graphicPreRenderSizeWidth = graphicPreRenderSizeWidth;
//			style.graphicPreRenderSizeHeight = graphicPreRenderSizeHeight;
		}

	}
	
}
