/**
 * @DATE 2016/3/9;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontWeight;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextRotation;

	import me.shunia.components.Layout;
	import me.shunia.components.Panel;
	
	public class ComplexTextLineRender {

		internal static var eventMirror:ComplexTextLineEventHandler = new ComplexTextLineEventHandler();

		internal static function render(line:*, style:ComplexTextStyle):DisplayObject {
			var p:Panel = setUpTextLineContainer(style);
			var t:TextBlock = setUpTextLineCreator(style);
			if (line is IComplexTextLine) line = [line];
			var g:ContentElement = groupLineConfigurations(line, style);
			t.content = g;

			var tl:TextLine = t.createTextLine(null, style.width);
			var wrapper:Sprite = null;
			while (tl) {
				// 这里加一个层级,用来展示下划线等功能
				wrapper = new Sprite();
				wrapper.addChild(tl);
				p.add(wrapper);
				tl = t.createTextLine(tl, style.width);
			}

			t.releaseLineCreationData();

			return p;
		}

		protected static function setUpTextLineContainer(style:ComplexTextStyle):Panel {
			var p:Panel = new Panel();
			if (style.vertical) {
				p.layout.type = Layout.VERTICAL;
				p.layout.vGap = style.lineGap + ComplexTextStyle.DEFAULT_GAP;
				p.layout.hGap = 0;
			} else {
				p.layout.type = Layout.HORIZONTAL;
				p.layout.hGap = style.lineGap + ComplexTextStyle.DEFAULT_GAP;
				p.layout.vGap = 0;
			}
			return p;
		}

		protected static function setUpTextLineCreator(style:ComplexTextStyle):TextBlock {
			var tb:TextBlock = new TextBlock();
			tb.baselineZero = TextBaseline.ASCENT;
			tb.baselineFontSize = style.fontSize;

			var fd:FontDescription = new FontDescription();
			fd.fontName = style.fontFamily;
			fd.fontWeight = style.fontBold ? FontWeight.BOLD : FontWeight.NORMAL;
			tb.baselineFontDescription = fd;
			tb.lineRotation = style.rotation == "vertical" ? TextRotation.ROTATE_90 : TextRotation.ROTATE_0;

			return tb;
		}

		protected static function groupLineConfigurations(lines:*, style:ComplexTextStyle):ContentElement {
			if (!lines || lines.length == 0) return null;
			if (lines.length == 1) return configToElement(lines[0], style);

			var elms:Vector.<ContentElement> = new <ContentElement>[];
			for (var i:int = 0, l:int = lines.length; i < l; i ++) {
				elms.push(configToElement(lines[i], style));
			}
			return new GroupElement(elms);
		}

		protected static function configToElement(config:IComplexTextLine, style:ComplexTextStyle):ContentElement {
			var fds:FontDescription = null;
			var fmt:ElementFormat = null;
			var elm:ContentElement = null;
			if (config is IComplexTextLineText) {
				var textConfig:ComplexTextLineTextImplementation = config as ComplexTextLineTextImplementation;
				if (textConfig && textConfig.getContent()) {
					fds = new FontDescription(
							textConfig.getFontFamily() ? textConfig.getFontFamily() : style.fontFamily,
							textConfig.getFontBold() ? "bold" : "normal");
					fmt = new ElementFormat(fds, textConfig.getFontSize(), textConfig.getFontColor());
					elm = new TextElement(textConfig.getContent(), fmt);
				}
			} else if (config is IComplexTextLineGraphic) {
				var graphicConfig:ComplexTextLineGraphicImplementation = config as ComplexTextLineGraphicImplementation;
				if (graphicConfig && graphicConfig.getContent()) {
					fds = new FontDescription(style.fontFamily, style.fontBold ? FontWeight.BOLD : FontWeight.NORMAL);
					fmt = new ElementFormat(fds, style.fontSize, style.fontColor);
					fmt.alignmentBaseline = TextBaseline.DESCENT;
					elm = new GraphicElement(
							graphicConfig.getContent(),
							graphicConfig.getWidth(),
							graphicConfig.getHeight(),
							fmt);
				}
			}

			if (eventMirror.validForInteraction(config)) {
				elm.userData = {"config": config, "style": style};
				elm.eventMirror = eventMirror;
			}

			return elm;
		}
	}
	
}
