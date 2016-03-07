/**
 * @DATE 2015/12/22;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {
	
	import flash.display.DisplayObject;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import me.shunia.components.*;

	public class ComplexText extends Panel {
		
		protected var _allLineConfigurations:Array = null;
		
		protected var _queuedLineConfigurations:Array = null;
		
		protected var _allLineComponents:Vector.<DisplayObject> = null;
		
		protected var _currentTextLineConfiguration:* = null;
		
		protected var _reRendering:Boolean = false;
		
		protected var _tick:uint = 0;

		protected var _convinient:Convinient = new Convinient();
		
		public function get convinient():Convinient {
			return _convinient;
		}
		
		public function ComplexText() {
			super();

			layout.type = Layout.VERTICAL;
			layout.vGap = 2;

			_queuedLineConfigurations = [];
			_allLineComponents = new <DisplayObject>[];
			_allLineConfigurations = [];
		}

		public function set style(value:ComplexTextStyle):void {
			if (value) {
				if (!convinient.style) {
					convinient.style = new ComplexTextStyle();
				}
				value.copy(convinient.style);
				pickUpGlobalOptions(convinient.style);

				_reRendering = true;
				reRender();
				_reRendering = false;
			}
		}

		protected function pickUpGlobalOptions(stl:ComplexTextStyle):void {
			if (stl.vertical) {
				layout.type = Layout.VERTICAL;
				layout.vGap = stl.paragraphGap;
				layout.hGap = 0;
			} else {
				layout.type = Layout.HORIZONTAL;
				layout.hGap = stl.paragraphGap;
				layout.vGap = 0;
			}
		}

		public function append(lineOrLines:*):void {
			_queuedLineConfigurations.push(lineOrLines);

			if (convinient.style && convinient.style.renderTick > 0)
				tickForRender();
			else
				render();
		}

		protected function get validForRender():Boolean {
			return !_currentTextLineConfiguration && _queuedLineConfigurations.length && !_reRendering;
		}

		protected function tickForRender():void {
			if (_tick == 0) {
				if (validForRender) {
					_tick = setTimeout(
							function ():void {
								render();
								clearTimeout(_tick);
								_tick = 0;
								tickForRender();
							},
							convinient.style.renderTick
					);
				}
			}
		}
		
		protected function render():void {
			if (validForRender) {
				_currentTextLineConfiguration = _queuedLineConfigurations.shift();
				var display:DisplayObject = ComplexTextLineRender.render(_currentTextLineConfiguration, convinient.style);
				if (display) {
					_allLineConfigurations.push(_currentTextLineConfiguration);
					_allLineComponents.push(display);
					add(display);
				}
				_currentTextLineConfiguration = null;
			}
		}

		protected function reRender():void {
			removeAll();

			_allLineComponents.length = 0;

			for (var i:int = 0, l:int = _allLineConfigurations.length; i < l; i ++) {
				_currentTextLineConfiguration = _allLineConfigurations[i];
				var display:DisplayObject = ComplexTextLineRender.render(_currentTextLineConfiguration, convinient.style);
				if (display) {
					_allLineComponents.push(display);
					add(display);
				}
			}
			_currentTextLineConfiguration = null;
		}

	}
	
}

import flash.display.DisplayObject;
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

import me.shunia.components.text.ComplexTextStyle;
import me.shunia.components.text.IComplexTextLine;
import me.shunia.components.text.IComplexTextLineGraphic;
import me.shunia.components.text.IComplexTextLineText;

class Convinient {

	internal var style:ComplexTextStyle = new ComplexTextStyle();

	public function createText():IComplexTextLineText {
		var text:ComplexTextLineTextImplementation = new ComplexTextLineTextImplementation();
		if (style) {
			text.fontBold = style.fontBold;
			text.fontColor = style.fontColor;
			text.fontItalic = style.fontItalic;
			text.fontFamily = style.fontFamily;
			text.fontSize = style.fontSize;
		}
		return text;
	}

	public function createGraphic():IComplexTextLineGraphic {
		var graphic:ComplexTextLineGraphicImplementation = new ComplexTextLineGraphicImplementation();
		if (style) {
			graphic.height = style.graphicPreRenderSizeHeight;
			graphic.width = style.graphicPreRenderSizeWidth;
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

class ComplexTextLineImplementation implements IComplexTextLine {

	public function ComplexTextLineImplementation() {

	}

}

class ComplexTextLineTextImplementation extends ComplexTextLineImplementation implements IComplexTextLineText {

	public var content:String = "";
	public var link:String = null;
	public var linkHandler:Function = null;
	public var fontFamily:String = null;
	public var fontSize:int = 12;
	public var fontColor:uint = 0;
	public var fontBold:Boolean = false;
	public var fontItalic:Boolean = false;
	public var underLine:Boolean = false;
	public var underLineColor:uint = 0xCCCCCC;

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
}

class ComplexTextLineGraphicImplementation extends ComplexTextLineImplementation implements IComplexTextLineGraphic {

	public var content:DisplayObject = null;
	public var link:String = null;
	public var linkHandler:Function = null;
	public var width:Number = 0;
	public var height:Number = 0;

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
}

class ComplexTextLineRender {

	internal static function render(line:*, style:ComplexTextStyle):DisplayObject {
		var p:Panel = setUpTextLineContainer(style);
		var t:TextBlock = setUpTextLineCreator(style);
		if (line is IComplexTextLine) line = [line];

		var g:ContentElement = groupLineConfigurations(line, style);
		t.content = g;
		var tl:TextLine = t.createTextLine(null, style.width);
		while (tl) {
			p.add(tl);
			tl = t.createTextLine(tl, style.width);
		}

		t.releaseLineCreationData();

		return p;
	}

	protected static function setUpTextLineContainer(style:ComplexTextStyle):Panel {
		var p:Panel = new Panel();
		if (style.vertical) {
			p.layout.type = Layout.VERTICAL;
			p.layout.vGap = style.lineGap;
			p.layout.hGap = 0;
		} else {
			p.layout.type = Layout.HORIZONTAL;
			p.layout.hGap = style.lineGap;
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
		if (config is IComplexTextLineText) {
			var textConfig:ComplexTextLineTextImplementation = config as ComplexTextLineTextImplementation;
			if (textConfig && textConfig.content) {
				fds = new FontDescription(
						textConfig.fontFamily ? textConfig.fontFamily : style.fontFamily,
						textConfig.fontBold ? "bold" : "normal");
				fmt = new ElementFormat(fds, textConfig.fontSize, textConfig.fontColor);
				return new TextElement(textConfig.content, fmt);
			}
		} else if (config is IComplexTextLineGraphic) {
			var graphicConfig:ComplexTextLineGraphicImplementation = config as ComplexTextLineGraphicImplementation;
			if (graphicConfig && graphicConfig.content) {
				fds = new FontDescription(style.fontFamily, style.fontBold ? FontWeight.BOLD : FontWeight.NORMAL);
				fmt = new ElementFormat(fds, style.fontSize, style.fontColor);
				fmt.alignmentBaseline = TextBaseline.DESCENT;
				return new GraphicElement(graphicConfig.content, graphicConfig.width, graphicConfig.height, fmt);
			}
		}
		return null;
	}

}
