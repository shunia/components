package me.shunia.components
{

	import flash.display.DisplayObject;
	import flash.utils.Dictionary;

	import me.shunia.components.interfaces.IItemRenderHolder;

	public class DataTab extends Tab implements IItemRenderHolder
	{
		
		protected var _data:Array = null;
		protected var _match:Dictionary = null;
		protected var _labelField:String = "label";
		
		public function DataTab() {
			super();
		}
		
		public function get data():Array {
			return _data;
		}

		public function set data(value:Array):void {
			if (value != _data) {
				_match = new Dictionary();
				_data = value;
				
				for (var i:int = 0; i < _data.length; i ++) {
					_addItemByData(_data[i]);
				}
			}
		}
		
		public function set itemRenderer(value:Class):void {
			// 这个控件暂时不支持设置ItemRender
			buttonClass = value;
		}

		public function get itemRenderer():Class {
			return _btnCls;
		}

		public function get labelField():String {
			return _labelField;
		}

		public function set labelField(value:String):void {
			_labelField = value;
		}
		
		public function addItemByData(data:*):void {
			var r:DisplayObject = _addItemByData(data);
			if (r) {
				if (_data && _data.indexOf(data) != -1) _data.push(data);
			}
		}
		
		protected function _addItemByData(data:*):DisplayObject {
			var d:DisplayObject = null;
			if (data) {
				var t:String = typeof data;
				if (t == "string") {
					d = addItem(t);
				} else {
					if (_labelField && _labelField.length) {
						d = addItem(data[_labelField]);
					}
				}
			}
			
			if (d) {
				if (!_match) _match = new Dictionary();
				_match[data] = d;
			}
			
			return d;
		}
		
		public function get selectedItem():* {
			return _data[selectedIndex];
		}
		
	}
}