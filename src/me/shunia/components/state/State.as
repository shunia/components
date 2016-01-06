/**
 * @DATE 2015/12/24;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.state {

	import flash.display.DisplayObject;

	import me.shunia.components.*;
	
	public class State extends Panel {
		
		protected var _states:Array = null;
		protected var _currentState:IStateComponent = null;
		
		public function State() {
			super();

			layout.type = Layout.NONE;

			_states = [];
		}

		public function get totalStateChildren():int {
			return _states.length;
		}
		
		public function get selectedState():IStateComponent {
			return _currentState;
		}

		public function get selectedIndex():int {
			return selectedState ? _states.indexOf(selectedState) : -1;
		}

		public function addState(state:IStateComponent):int {
			// 不管存在不存在,不存在直接添加到最后,存在的话相当于调整index
			_states.push(state);
			var index:int = _states.indexOf(state);

			if (!_currentState)
				switchState(index);

			return index;
		}
		
		public function switchState(index:int, ...args):void {
			if (index < _states.length) {
				var state:IStateComponent = _states[index];
				if (state) {
					if (_currentState)
						super.remove(_currentState as DisplayObject);
					super.add(state as DisplayObject);
					if (state.dataHandler != null) {
						while (args.length > state.dataHandler.length) {
							args.pop();
						}
						try {
							state.dataHandler.apply(null, args);
						} catch (e:Error) {};
					}
				}
			}
		}

		override public function add(d:DisplayObject):DisplayObject {
			if (!(d is IStateComponent)) {
				d = new WrapperState(d);
			}
			addState(d as IStateComponent);
			return d;
		}

		override public function remove(d:DisplayObject):void {
			if (!(d is IStateComponent)) {
				var st:IStateComponent = null;
				for (var i:int = 0; i < _states.length; i ++) {
					if (d === _states[i].display) {
						st = _states[i];
						break;
					}
				}
				if (st) {
					_states.splice(_states.indexOf(st), 1);
					super.remove(st as DisplayObject);
				}
			} else {
				super.remove(d);
			}
		}

	}

}

import flash.display.DisplayObject;

import me.shunia.components.Panel;
import me.shunia.components.state.IStateComponent;

class WrapperState extends Panel implements IStateComponent {

	protected var _display:DisplayObject = null;
	
	public function WrapperState(d:DisplayObject) {
		_display = d;
		add(_display);
	}
	
	public function get dataHandler():Function {
		return null;
	}
	
	public function get display():DisplayObject {
		return _display;
	}
}