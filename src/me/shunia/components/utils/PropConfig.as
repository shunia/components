package me.shunia.components.utils
{

	import flash.utils.Dictionary;

	public class PropConfig
	{
		
		protected var _props:Dictionary = null;
		protected var _length:int = 0;
		
		public function PropConfig()
		{
			_props = new Dictionary();
			_length = 0;
		}
		
		public function setProp(k:String, value:*):void {
			if (!hasProp(k)) 
				_length ++;
			_props[k] = value;
		}
		
		public function hasProp(k:String):Boolean {
			return _props.hasOwnProperty(k);
		}
		
		public function getProp(k:String):* {
			return hasProp(k) ? _props[k] : null;
		}
		
		public function safeProp(k:String, def:* = null):* {
			var r:* = def;
			if (_props.hasOwnProperty(k)) {
				r = _props[k];
				delete _props[k];
				_length --;
			}
			return r;
		}
		
		public function get length():int {
			return _length;
		}
		
		public function clone():PropConfig {
			var prop:PropConfig = new PropConfig();
			for (var k:String in _props) {
				prop.setProp(k, _props[k]);
			}
			return prop;
		}
		
	}
}