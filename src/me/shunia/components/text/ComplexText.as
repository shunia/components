/**
 * @DATE 2015/12/22;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.text {
	
	import flash.display.DisplayObject;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import me.shunia.components.Layout;
	import me.shunia.components.Panel;
	import me.shunia.components.text.ComplexTextConvinient;

	public class ComplexText extends Panel {
		
		protected var _allLineConfigurations:Array = null;
		
		protected var _queuedLineConfigurations:Array = null;
		
		protected var _currentTextLineConfiguration:* = null;
		
		protected var _reRendering:Boolean = false;
		
		protected var _tick:uint = 0;

		protected var _convinient:ComplexTextConvinient = new ComplexTextConvinient();
		
		public function get convinient():ComplexTextConvinient {
			return _convinient;
		}
		
		public function ComplexText() {
			super();

			layout.type = Layout.VERTICAL;
			layout.vGap = 2;

			_queuedLineConfigurations = [];
			_allLineConfigurations = [];
		}

		public function set style(value:ComplexTextStyle):void {
			if (value) {
				if (!convinient.style) {
					convinient.style = new ComplexTextStyle();
				}
				value.copyTo(convinient.style);
				pickUpGlobalOptions(convinient.style);

				_reRendering = true;
				reRender();
				_reRendering = false;
			}
		}

		protected function pickUpGlobalOptions(stl:ComplexTextStyle):void {
			if (stl.vertical) {
				layout.type = Layout.VERTICAL;
				layout.vGap = stl.paragraphGap + ComplexTextStyle.DEFAULT_GAP;
				layout.hGap = 0;
			} else {
				layout.type = Layout.HORIZONTAL;
				layout.hGap = stl.paragraphGap + ComplexTextStyle.DEFAULT_GAP;
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
					add(display);
				}
				_currentTextLineConfiguration = null;
			}
		}

		protected function reRender():void {
			removeAll();

			for (var i:int = 0, l:int = _allLineConfigurations.length; i < l; i ++) {
				_currentTextLineConfiguration = _allLineConfigurations[i];
				var display:DisplayObject = ComplexTextLineRender.render(_currentTextLineConfiguration, convinient.style);
				if (display) {
					add(display);
				}
			}
			_currentTextLineConfiguration = null;
		}

	}
	
}
