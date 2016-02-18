/**
 * Created by qingfenghuang on 2015/5/21.
 */
package me.shunia.components {
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Label extends TextField {
		
		protected var _fmt:TextFormat = null;
		protected var _trim:Boolean = false;
		protected var _text:String = "";
		protected var _trimRpl:String = "...";
		protected var _trimChecking:Boolean = false;
		protected var _maxWidth:Number = 0;
		protected var _actualWidth:Number = 0;
		
	    public function Label() {
			super();
			
			_fmt = new TextFormat();
			_fmt.color = 0;
			_fmt.font = "Microsoft YaHei,微软雅黑,宋体";
		    _fmt.size = 12;
	        this.defaultTextFormat = _fmt;
			
			autoSize = TextFieldAutoSize.LEFT;
			selectable = false;
			mouseEnabled = false;
	    }
		
		public function set maxWidth(value:Number):void {
			_maxWidth = value;
			_trim = true;
			trimCheck();
		}

		override public function set width(value:Number):void {
			super.width = value;
			_actualWidth = value;
			_trim = true;
			trimCheck();
		}
		
		public function set color(value:uint):void {
			_fmt.color = value;
			updateFormat();
		}
		public function get color():uint {
			return uint(_fmt.color);
		}
		
		public function set size(value:int):void {
			_fmt.size = value;
			updateFormat();
		}
		public function get size():int {
			return int(_fmt.size);
		}
		
		public function set font(value:String):void {
			_fmt.font = value;
			updateFormat();
		}
		public function get font():String {
			return _fmt.font;
		}
		
		public function set align(value:String):void {
			_fmt.align = value;
			updateFormat();
		}
		public function get align():String {
			return _fmt.align;
		}
		
		public function set bold(value:Boolean):void {
			_fmt.bold = value;
			updateFormat();
		}
		public function get bold():Boolean {
			return _fmt.bold;
		}
		
		public function set italic(value:Boolean):void {
			_fmt.italic = value;
			updateFormat();
		}
		public function get italic():Boolean {
			return _fmt.italic;
		}
		
		public function set underline(value:Boolean):void {
			_fmt.underline = value;
			updateFormat();
		}
		public function get underline():Boolean {
			return _fmt.underline;
		}
		
		override public function set text(value:String):void {
			if (value == null) value = "";
			super.text = value;
			if (!_trimChecking) 
				_text = value;
			trimCheck();
		}
		
		/**
		 * 是否自动省略过长部分.
		 *  
		 * @param value
		 */		
		public function set trim(value:Boolean):void {
			_trim = value;
			trimCheck();
		}
		
		/**
		 * 自动过长被省略的部分将用如下该字符代替.
		 *  
		 * @param value
		 */		
		public function set trimRpl(value:String):void {
			_trimRpl = value ? value : "...";
			trimCheck();
		}
		
		protected function trimCheck():void {
			if (_trimChecking) return;
			// 只有需要自动省略,并且存在文字内容,并且设定了宽度才能触发逻辑
			if (_trim && _text) {
				_trimChecking = true;

				var t:String = _text,
					w:Number = getTextWidth(t);
				if (_actualWidth > 0 && w < _actualWidth) {
					append(t, w);
				} else if (_maxWidth > 0 && w > _maxWidth) {
					deduct(t, w);
				}
				_trimChecking = false;
			}
		}

		/**
		 * 在原文字内容后填充空格以补足长度
		 *
		 * @param t
		 * @param originalWidth
		 * */
		protected function append(t:String, originalWidth:Number):void {
			var r:String = "  ",
				rw:Number = getTextWidth(r);
			while ((originalWidth + rw) < _actualWidth) {
				t += r;
				originalWidth = getTextWidth(t);
			}
			text = t;
		}

		/**
		 * 缩短原文字长度,并在最后填充 _trimRpl 以补足长度
		 *
		 * @param t
		 * @param originalWidth
		 * */
		protected function deduct(t:String, originalWidth:Number):void {
			var r:String = _trimRpl,
				rw:Number = getTextWidth(r);
			while ((originalWidth + rw) > _maxWidth) {
				t = t.substr(0, t.length - 1);
				originalWidth = getTextWidth(t);
			}
			text = t + r;
		}
		
		protected function getTextWidth(t:String):Number {
			text = t;
			return super.width;
		}
		
		protected function updateFormat():void {
			defaultTextFormat = _fmt;
			setTextFormat(_fmt);
			trimCheck();
		}
		
	}
}
