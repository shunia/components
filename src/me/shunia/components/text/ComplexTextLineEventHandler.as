/**
 * @DATE 2016/3/9;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {

	import flash.display.Sprite;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;

	public class ComplexTextLineEventHandler extends EventDispatcher {

		protected var _overCache:Dictionary = null;

		public function ComplexTextLineEventHandler() {
			super(null);

			_overCache = new Dictionary();

			addEventListener(MouseEvent.CLICK, onInteraction);
			addEventListener(MouseEvent.MOUSE_OVER, onInteraction);
			addEventListener(MouseEvent.MOUSE_OUT, onInteraction);
		}

		protected function onInteraction(e:MouseEvent):void {
			if (e.type == MouseEvent.MOUSE_OUT) {
				var tl:TextLine = e.currentTarget as TextLine;
				if (_overCache[tl]) {
					_overCache[tl].graphics.clear();
					delete _overCache[tl];
				}
				mouseOut();
			} else {
				var region:TextLineMirrorRegion = getRegion(e);
				if (region) {
					var config:IComplexTextLine = region.element.userData.config as IComplexTextLineText;
					var style:ComplexTextStyle = region.element.userData.style as ComplexTextStyle;
					if (!validForInteraction(config)) return;

					switch (e.type) {
						case MouseEvent.CLICK :
							goForLink(region, config, style);
							break;

						case MouseEvent.MOUSE_OVER :
							var holder:Sprite = underLine(region, config, style);
							if (holder) {
								mouseOver();
								_overCache[region.textLine] = holder;
							}
							break;
					}
				}
			}
		}

		protected function goForLink(region:TextLineMirrorRegion, config:IComplexTextLine, style:ComplexTextStyle):void {
			var link:String = null, handler:Function = null;
			if (config is IComplexTextLineText) {
				link = (config as IComplexTextLineText).getLink();
				handler = (config as IComplexTextLineText).getLinkHandler();
			} else {
				link = (config as IComplexTextLineGraphic).getLink();
				handler = (config as IComplexTextLineGraphic).getLinkHandler();
			}
			// 回调方法
			if (handler != null) {
				// 暂时没想明白需要传什么参数,默认不给参数先
				handler.apply();
			}
			// 跳转链接
			if (link && link.length > 0) {
				navigateToURL(new URLRequest(link), "_blank");
			}
		}

		protected function underLine(region:TextLineMirrorRegion, config:IComplexTextLine, style:ComplexTextStyle):Sprite {
			var valid:Boolean = style.underLineForLink || config is IComplexTextLineText;
			if (valid) {
				var underLineHolder:Sprite = region.textLine.parent as Sprite;
				if (underLineHolder) {
					underLineHolder.graphics.clear();
					var color:uint = config is IComplexTextLineText ?
							(config as IComplexTextLineText).getUnderLineColor() :
							style.underLineColor;
					underLineHolder.graphics.lineStyle(style.underLineThickness, color);
					if (style.vertical) {
						underLineHolder.graphics.moveTo(region.bounds.x, region.bounds.height);
						underLineHolder.graphics.lineTo(region.bounds.width, region.bounds.height);
					} else {
						underLineHolder.graphics.moveTo(region.bounds.x, region.bounds.y);
						underLineHolder.graphics.lineTo(region.bounds.x, region.bounds.height);
					}
				}
				return underLineHolder;
			}
			return null;
		}

		protected function mouseOver():void {
			Mouse.cursor = MouseCursor.BUTTON;
		}

		protected function mouseOut():void {
			Mouse.cursor = MouseCursor.AUTO;
		}

		protected function getRegion(e:MouseEvent):TextLineMirrorRegion {
			var line:TextLine = e.currentTarget as TextLine;
			var region:TextLineMirrorRegion = null;
			if (line && line.mirrorRegions && line.mirrorRegions.length) {
				var pos:Point = line.globalToLocal(new Point(e.stageX, e.stageY));
				var index:int = 0;
				var nextRegion:TextLineMirrorRegion = null;
				while (index < line.mirrorRegions.length) {
					nextRegion = line.mirrorRegions[index];
					if (nextRegion.bounds.containsPoint(pos)) {
						region = nextRegion;
						break;
					}
					index ++;
				}
			}

			return region;
		}

		public function validForInteraction(config:IComplexTextLine):Boolean {
			if (config) {
				if (config is IComplexTextLineText) {
					var textConfig:IComplexTextLineText = config as IComplexTextLineText;
					return textConfig.getLink() != null ||
									textConfig.getLinkHandler() != null;
				} else if (config is IComplexTextLineGraphic) {
					var graphicConfig:IComplexTextLineGraphic = config as IComplexTextLineGraphic;
					return graphicConfig.getLink() != null ||
									graphicConfig.getLinkHandler() != null;
				}
			}

			return false;
		}

	}
	
}
