/**
 * @DATE 2016/3/9;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {
	
	public class ComplexTextConvinient {

		internal var style:ComplexTextStyle = null;

		public function createText():IComplexTextLineText {
			var text:ComplexTextLineTextImplementation = new ComplexTextLineTextImplementation();
			if (style) {
				text.setFontBold(style.fontBold);
				text.setFontColor(style.fontColor);
				text.setFontFamily(style.fontFamily);
				text.setFontItalic(style.fontItalic);
				text.setFontSize(style.fontSize);
				text.setUnderLineColor(style.underLineColor);
			}
			return text;
		}

		public function createGraphic():IComplexTextLineGraphic {
			var graphic:ComplexTextLineGraphicImplementation = new ComplexTextLineGraphicImplementation();
			if (style) {
				graphic.setHeight(style.graphicPreRenderSizeHeight);
				graphic.setWidth(style.graphicPreRenderSizeWidth);
			}
			return graphic;
		}

		public function join(...args):Vector.<IComplexTextLine> {
			if (args.length == 0) return null;

			var joined:Vector.<IComplexTextLine> = new <IComplexTextLine>[];
			for (var i:int = 0, l:int = args.length; i < l; i ++) {
				if (args[i] is IComplexTextLine) {
					joined.push(args[i]);
				}
			}
			return joined;
		}
	}
	
}
