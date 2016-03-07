package me.shunia.components
{
	
	import com.worlize.gif.GIFPlayer;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import me.shunia.components.utils.AssetLoader;
	
	/**
	 * 图标控件类
	 *  
	 * @author qingfenghuang
	 */	
	public class Asset extends Panel
	{
		
		protected var _url:String = null;
		protected var _source:DisplayObject = null;
		protected var _loader:AssetLoader = null;
		
		public function Asset(url:String = null)
		{
			super();
			
			layout.type = Layout.VERTICAL;
			layout.align = Layout.ALIGN_CENTER;
			
			this.url = url;
		}
		
		public function set url(value:String):void {
			if (value != _url) {
				removeAll();
				if (value) {
					_url = value;
					load();
				}
			}
		}
		
		public function get url():String {
			return _url;
		}

		public function get source():DisplayObject {
			return _source;
		}
		
		protected function load():void {
			if (!_loader) 
				_loader = new AssetLoader();
			_loader.load(_url, {"cache": false, "onComplete": onComplete});
		}
		
		protected function onComplete(result:*):void {
			_source = result as DisplayObject;
			if (_source) {
				removeAll();
				fitSource();
				add(_source);

				dispatchEvent(new CompEvents(CompEvents.COMPLETE));
			}
		}
		
		override public function set width(value:Number):void {
			fitSource();
			super.width = value;
		}
		
		override public function set height(value:Number):void {
			fitSource();
			super.height = value;
		}
		
		protected function fitSource():void {
			if (width == 0 || height == 0) return;
			
			if (_source && _source.width != width && _source.height != height) {
				_source.width = width;
				_source.height = height;
			}
		}

		override public function set visible(value:Boolean):void {
			super.visible = value;

			// 这里为影片剪辑和gif写一个优化
			if (source && (source is MovieClip || source is GIFPlayer)) {
				if (visible) source["gotoAndPlay"](1);
				else source["gotoAndStop"](1);
			}
		}
		
	}

}