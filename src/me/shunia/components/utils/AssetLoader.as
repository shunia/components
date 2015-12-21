package me.shunia.components.utils {
	
	import com.worlize.gif.GIFPlayer;
	import com.worlize.gif.events.AsyncDecodeErrorEvent;
	import com.worlize.gif.events.GIFPlayerEvent;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class AssetLoader {
		
		public static const EXT_BINARY:String = "!binary";
		public static const EXT_SWF:String = "!swf";
		public static const EXT_IMAGE:String = "!image";
		public static const EXT_TEXT:String = "!text";
		public static const EXT_JSON:String = "!json";
		public static const EXT_GIF:String = "!gif";
		
		protected static const LOADING_QUEUE:Dictionary = new Dictionary();
		protected static const CACHE:Dictionary = new Dictionary();
		
		protected static const OPTIONS:Object = {
			"autoStart": true, 
			"ext": null, 
			"onComplete": null, 
			"swfKey": null, 
			"cache": false
		};
		
		protected var _url:String = null;
		protected var _digest:String = null;
		protected var _loading:Boolean = false;
		protected var _loaded:Boolean = false;
		protected var _data:* = null;
		protected var _loader:BytesLoader = null;
		
		protected var _acceptedOptions:Object = {
			"autoStart": true,
            "ext": null,
			"onComplete": null,
			"swfKey": null, 
			"cache": false
		};
		
		public function get url():String {
			return _url;
		}
		
		public function set url(value:String):void {
			load(value, _acceptedOptions);
		}
		
		public function get options():Object {
			return _acceptedOptions;
		}
		
		public function set options(value:Object):void {
			load(url, value);
		}
		
		public function get loaded():Boolean {
			return _loaded;
		}
		
		public function get loading():Boolean {
			return _loading;
		}
		
		public function get ext():String {
            if (_acceptedOptions["ext"]) return _acceptedOptions["ext"];
			else if (url) return parseExt(url);
			return null;
		}
		
		public function get data():* {
			return _data;
		}
		
		public function AssetLoader(url:String = null, options:Object = null) {
			load(url, options);
		}
		
		protected function mergeOptions(options:Object = null):void {
			if (!options) return;
			
			for (var k:String in _acceptedOptions) {
				if (options.hasOwnProperty(k)) 
					_acceptedOptions[k] = options[k];
			}
		}
		
		public function load(url:String = null, options:Object = null):void {
			mergeOptions(options);
			
			init(url);
		}
		
		protected function init(url:String):void {
			_url = url;
			_loaded = false;
			_loading = true;
			
			if (!url && _data) {
				_data = null;
				dispose();
				_loaded = true;
				_loading = false;
			} else if (url) {
				process(url);
			}
		}
		
		protected function process(url:String):void {
			// 获取digest
			var digest:String = getDigest(url);
//			if (ext == EXT_GIF) 
//				trace(digest + ": 启动加载");
			// 根据不同情况选择缓存或者重新加载
			if (digest == _digest && _data) {
				applyResult(_data);
				_loaded = true;
			} else if (CACHE.hasOwnProperty(digest)) {
				_digest = digest;
//				if (ext == EXT_GIF) 
//					trace(_digest + ": 缓存命中,通过缓存返回");
				onResult(CACHE[digest]);
				_loaded = true;
			} else {
				_digest = digest;
//				if (ext == EXT_GIF) 
//					trace(_digest + ": 缓存未命中,准备加载");
				_data = null;
				_loaded = false;
				
				if (!cacheLoadingQueue()) {
//					if (ext == EXT_GIF) 
//						trace(_digest + ": 加载");
					if (!_loader) _loader = new BytesLoader(onResult);
					_loader.url = url;
				} else {
//					if (ext == EXT_GIF) 
//						trace(_digest + ": 缓存入加载队列");
				}
			}
		}
		
		/**
		 * 为了保证只加载一次相同的资源,用一个字典存入当前所有对同一个资源的回调引用,当可能需要
		 * 加载时,检查字典里对该资源的引用数组,如果已有引用,说明资源正在加载,需要把当前引用也缓
		 * 存起来,统一等待加载完成来回调.
		 *  
		 * @return 
		 */		
		protected function cacheLoadingQueue():Boolean {
			var cached:Boolean = false;
			if (_acceptedOptions["cache"]) {
				var arr:Array = LOADING_QUEUE[_digest];
				if (arr && arr.length > 0) 
					cached = true;
				if (!arr) arr = [];
				if (arr.indexOf(postResult) == -1) 
					arr.push(postResult);
				LOADING_QUEUE[_digest] = arr;
			}
			return cached;
		}
		
		protected function onResult(result:*):void {
			var ba:ByteArray = result as ByteArray;
			if (ba) {
				if (_acceptedOptions["cache"]) {
					CACHE[_digest] = ba;
					
					if (LOADING_QUEUE[_digest]) {
						var q:Array = LOADING_QUEUE[_digest];
						for each (var cb:Function in q) {
//							if (ext == EXT_GIF) 
//								trace(_digest + ": 从缓存加载队列中回调");
							cb.apply(null, [ba]);
						}
						delete LOADING_QUEUE[_digest];
					} else {
//						if (ext == EXT_GIF) 
//							trace(_digest + ": 直接回调");
						postResult(ba);
					}
				} else {
					postResult(ba);
				}
			} else {
				var error:Error = result as Error;
				if (error) {
					trace(error.errorID + ":" + error.message);
//					throw error;
				}
			}
			_loaded = true;
			_loading = false;
		}
		
		protected function postResult(data:ByteArray):void {
			var ext:String = ext,
				swfKey:String = _acceptedOptions["swfKey"];
			data = cloneBytes(data);
			byteToType(applyResult, data, ext, swfKey);
		}
		
		protected function cloneBytes(bytes:ByteArray):ByteArray {
			var copy:ByteArray = new ByteArray();
			copy.writeObject(bytes);
			copy.position = 0;
			return copy.readObject() as ByteArray;
		}
		
		protected function applyResult(data:*):void {
			var onComplete:Function = _acceptedOptions["onComplete"];
			if (onComplete != null) {
				onComplete.apply(null, [data]);
			}
			
			_data = data;
		}
		
		/**
		 * 把加载到的二进制数据根据类型转换成对应的数据类型.
		 *  
		 * @param ba 原始二进制数据
		 * @param ext 类型
		 * @param swfKey 假如是swf类型,这个字段根据实际情况提供,其他类型此字段无用
		 * @return 对应各个类型的数据类型
		 */	
		protected function byteToType(onComplete:Function, ba:ByteArray, ext:String, swfKey:String = null):void {
			if (ext == EXT_SWF || ext == EXT_IMAGE) {
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(
						Event.COMPLETE,
						function (c:Function, k:String = null):Function {
							return function (e:Event):void {
								var loaderInfo:LoaderInfo = e.target as LoaderInfo;
								var swfOrImage:* = loaderInfo.content;
								if (swfOrImage is MovieClip && k) {
									var def:Class = loaderInfo.applicationDomain.getDefinition(swfKey) as Class;
									swfOrImage = new def();
								}

								if (c != null) c.apply(null, [swfOrImage]);
							}
						}(onComplete, swfKey));
				loader.loadBytes(ba);
			} else if (ext == EXT_GIF) {
				var gif:GIFPlayer = new GIFPlayer();
				gif.addEventListener(
						GIFPlayerEvent.COMPLETE,
						function (g:GIFPlayer, c:Function):Function {
							return function (e:Event):void {
								if (c != null) c.apply(null, [g]);
							}
						}(gif, onComplete));
				gif.addEventListener(AsyncDecodeErrorEvent.ASYNC_DECODE_ERROR,
					function (e:AsyncDecodeErrorEvent):void {
						trace("Gif decode error!");
						if (onComplete != null) onComplete.apply(null, [e]);
					});
				gif.loadBytes(ba);
			} else {
				var t:* = null;
				switch (ext) {
					case EXT_TEXT : 
						t = ba.readUTFBytes(ba.bytesAvailable);
						break;
					case EXT_JSON : 
						t = JSON.parse(ba.readUTFBytes(ba.bytesAvailable));
						break;
					default : 
						t = ba;
						break;
				}
				if (onComplete != null) onComplete.apply(null, [t]);
			}
		}

		/**
		 * 对url做hash处理从而得到带类似于版本号的缓存key.
		 *  
		 * @param url
		 * @return 
		 */	
		protected function getDigest(url:String):String {
			var digestPart:String = url.substring(url.lastIndexOf("/") + 1, url.length);
//			var digest:String = MD5.hash(digestPart);
			return digestPart;
		}
		
		/**
		 * 根据链接获取类型.如果没有匹配的类型,默认当二进制处理.
		 * 匹配的逻辑是取链接最后几个字符串来进行扩展名匹配.
		 *  
		 * @param url
		 * @return 
		 */	
		protected function parseExt(url:String):String {
			var ext:String = url.substring(url.length - 5, url.length).toLowerCase();
			if (ext.indexOf(".swf") == 1) 
				return EXT_SWF;
			else if (ext.indexOf(".png") == 1 || ext.indexOf(".jpg") == 1 || ext.indexOf(".bmp") == 1 || ext.indexOf(".jpeg") == 0) 
				return EXT_IMAGE;
			else if (ext.indexOf(".gif") == 1) 
				return EXT_GIF;
			else if (ext.indexOf(".txt") == 1 || ext.indexOf(".text") == 1) 
				return EXT_TEXT;
			else if (ext.indexOf(".json") == 1) 
				return EXT_JSON;
			return EXT_BINARY;
		}
		
		public function dispose():void {
			_loaded = false;
			_loading = false;
			_data = null;
			_url = null;
			for (var k:String in _acceptedOptions) {
				_acceptedOptions[k] = OPTIONS[k];
			}
		}
		
	}
}

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

class BytesLoader extends URLLoader {
	
	protected var _url:String = null;
	protected var _onComplete:Function = null;
	protected var _isLoading:Boolean = false;
	
	public function BytesLoader(onComplete:Function = null):void {
		super();
		_onComplete = onComplete;
		dataFormat = URLLoaderDataFormat.BINARY;
	}
	
	public function set onComplete(value:Function):void {
		_onComplete = value;
	}
	
	public function set url(value:String):void {
		if (_isLoading) {
			try { 
				close(); 
			} catch (e:Error) {}
		}
		_isLoading = false;
		_url = value;
		start();
	}
	
	protected function start():void {
		_isLoading = true;
		var req:URLRequest = new URLRequest(_url);
		req.contentType = "application/octet-stream";
		addEventListener(Event.COMPLETE, onLoaded);
		addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		load(req);
	}
	
	protected function onLoaded(e:Event):void {
		_isLoading = false;
		if (_onComplete != null) 
			_onComplete.apply(null, [data]);
	}
	
	protected function onIOError(e:IOErrorEvent):void {
		_isLoading = false;
		if (_onComplete != null) 
			_onComplete.apply(null, [new Error(e.toString(), e.errorID)]);
	}
	
	protected function onSecurityError(e:SecurityErrorEvent):void {
		_isLoading = false;
		if (_onComplete != null) 
			_onComplete.apply(null, [new Error(e.toString(), e.errorID)]);
	}
	
}