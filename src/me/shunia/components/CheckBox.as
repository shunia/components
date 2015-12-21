/**
 * Created by qingfenghuang on 2015/5/21.
 */
package me.shunia.components {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[Event(name="change", type="me.shunia.components.CompEvents")]
	
	public class CheckBox extends Panel {
		
	    private var _selected:Boolean = false;
	    private var _label:Label = null;
		protected var _asset:MovieClip = null;
	    private var _box:Sprite = null;
	
	    public function CheckBox() {
	        super();
			
			buttonMode = true;
			useHandCursor = true;
			
			layout.align = Layout.ALIGN_CENTER;
	
	        _label = new Label();
			_label.mouseEnabled = false;
	        _box = new Sprite();
	        drawBox();
	        add(_box);
	        add(_label);
	
	        addEventListener(MouseEvent.CLICK, onClick);
	    }
		
		protected function onClick(e:Event):void {
			selected = !_selected;
			dispatchEvent(new CompEvents(CompEvents.CHANGE));
		}
		
		public function set asset(value:MovieClip):void {
			while (_box.numChildren) _box.removeChildAt(0);
			
			_asset = value;
			_asset.gotoAndStop(1);
			updateCheck();
		}
		
		public function set label(value:String):void {
			if (_label) 
				_label.text = value;
			layout.updateDisplay();
		}
		
		public function set labelSize(value:int):void {
			if (_label) 
				_label.size = value;
			layout.updateDisplay();
		}
		
		public function set labelColor(value:uint):void {
			if (_label) 
				_label.color = value;
		}
		
	    public function get selected():Boolean {
	        return _selected;
	    }
	
	    public function set selected(value:Boolean):void {
	        if (value != _selected) {
	            _selected = value;
	            updateCheck();
	        }
	    }
		
		protected function updateCheck():void {
			if (_asset == null) {
				drawBox();
			} else {
				_box.graphics.clear();
				if (!_box.contains(_asset)) _box.addChild(_asset);
				_asset.gotoAndStop(_selected ? 2 : 1);
			}
			layout.updateDisplay();
		}
	
	    protected function drawBox():void {
	        var w:int = _label.height - 2;
	        _box.graphics.clear();
	        _box.graphics.lineStyle(2, 0);
	        _box.graphics.drawRect(1, 1, w, w);
	        if (_selected) {
	            _box.graphics.beginFill(0x000000);
	            _box.graphics.drawRect(4, 4, w - 6, w - 6);
	        }
	        _box.graphics.endFill();
	    }
	
	}
}
