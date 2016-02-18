package me.shunia.components.utils {
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/**
	 * 资源加载器,目前默认支持多种形式,由该类的静态属性定义.
	 * */
	public class AssetLoader {

		/**
		 * 二进制格式
		 * */
		public static const EXT_BINARY:String = "!binary";
		/**
		 * SWF格式(支持直接返回swf或根据swf中的类名返回实例)
		 * */
		public static const EXT_SWF:String = "!swf";
		/**
		 * 图片格式(目前支持png,jpg)
		 * */
		public static const EXT_IMAGE:String = "!image";
		/**
		 * 文本格式
		 * */
		public static const EXT_TEXT:String = "!text";
		/**
		 * JSON格式(返回JSON Object)
		 * */
		public static const EXT_JSON:String = "!json";
		/**
		 * GIF格式(返回可以播放的显示对象)
		 * */
		public static const EXT_GIF:String = "!gif";
		/**
		 * 加载队列缓存,用来防止同一资源发出多次加载请求
		 * */
		protected static const LOADING_QUEUE:Dictionary = new Dictionary();
		/**
		 * 加载完成的缓存,用来提供快速的缓存索引 {key: String, value: ByteArray}
		 * */
		protected static const CACHE:Dictionary = new Dictionary();
		/**
		 * 加载器接收的选项,默认值和参数都在这里了.
		 * */
		protected static const OPTIONS:Object = {
			"autoStart": true, 
			"ext": null, 
			"onComplete": null, 
			"swfKey": null, 
			"cache": false
		};
		/**
		 * 加载的路径
		 * */
		protected var _url:String = null;
		/**
		 * 加载的缩略信息,用来当作缓存的key
		 * */
		protected var _digest:String = null;
		/**
		 * 是否正在加载
		 * */
		protected var _loading:Boolean = false;
		/**
		 * 是否已加载
		 * */
		protected var _loaded:Boolean = false;
		/**
		 * 加载完成后的数据,可能是数据,可能是异常事件或者Error等,使用之前需要自行判断处理
		 * */
		protected var _data:* = null;
		/**
		 * 二进制加载器
		 * */
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
			// 假如不提供完成回调函数,也就意味着并不需要解析,在之前已经把这次的加载数据缓存起来了
			// 所以这里断开后续操作
			var onComplete:Function = _acceptedOptions["onComplete"];
			if (onComplete == null) {
				_data = data;
				return;
			}

			// 准备解析成显示对象
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
			var t:* = null;
			switch (ext) {
				case EXT_SWF :
						new SWFParser(ba, onComplete, swfKey);
					break;
				case EXT_IMAGE :
						new IMAGEParser(ba, onComplete);
					break;
				case EXT_GIF :
						new GIFParser(ba, onComplete);
					break;
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
			if (t && onComplete != null) onComplete.apply(null, [t, null]);
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

		/**
		 * 释放资源
		 * */
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

import com.worlize.gif.GIFPlayer;
import com.worlize.gif.events.AsyncDecodeErrorEvent;
import com.worlize.gif.events.GIFPlayerEvent;

import flash.display.Bitmap;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

/**
 * 二进制加载器,AssetLoader把所有的资源都先用二进制的方式加载进来,留待后续处理.
 * 主要使用URLLoader实现.
 * */
class BytesLoader extends URLLoader {

	/**
	 * 加载的路径
	 * */
	protected var _url:String = null;
	/**
	 * 成功回调方法
	 * */
	protected var _onComplete:Function = null;
	/**
	 * 是否正在加载的标记
	 * */
	protected var _isLoading:Boolean = false;

	/**
	 * 构造方法.
	 * 可以提供回调方法作为参数.
	 * */
	public function BytesLoader(onComplete:Function = null):void {
		super();
		// 把回调方法存起来
		_onComplete = onComplete;
		// 只用二进制的方式加载
		dataFormat = URLLoaderDataFormat.BINARY;
	}

	/**
	 * 动态设置回调方法
	 * */
	public function set onComplete(value:Function):void {
		_onComplete = value;
	}

	/**
	 * 动态设置加载路径.
	 * */
	public function set url(value:String):void {
		if (_isLoading) {
			// 假如已经在加载了,需要先尝试关闭通道
			try { 
				close(); 
			} catch (e:Error) {}
		}
		// 启动加载
		_isLoading = false;
		_url = value;
		start();
	}
	
	protected function start():void {
		_isLoading = true;
		var req:URLRequest = new URLRequest(_url);
		// 确保加载方式是二进制,设置这个属性会导致发出的请求里header中的contentType属性
		// 也是这个值.对于绝大部分的静态文件服务,应该都支持这个contentType.
		req.contentType = "application/octet-stream";
		addEventListener(Event.COMPLETE, onLoaded);
		addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		load(req);
	}

	/**
	 * 加载成功回调
	 * */
	protected function onLoaded(e:Event):void {
		_isLoading = false;
		if (_onComplete != null) 
			_onComplete.apply(null, [data]);
	}

	/**
	 * IO异常
	 * */
	protected function onIOError(e:IOErrorEvent):void {
		_isLoading = false;
		if (_onComplete != null) 
			_onComplete.apply(null, [new Error(e.toString(), e.errorID)]);
	}

	/**
	 * 跨域等安全异常
	 * */
	protected function onSecurityError(e:SecurityErrorEvent):void {
		_isLoading = false;
		if (_onComplete != null) 
			_onComplete.apply(null, [new Error(e.toString(), e.errorID)]);
	}
	
}

/**
 * 实现一个Parse类,用来结构原来的匿名函数处理异步处理二进制数据的逻辑.
 * 因为目前看来匿名函数和异步逻辑配合时,在渲染或解析有压力的情况会出现
 * 错乱的情况.
 *
 * 下一步可以在这里实现简单的资源池功能,通过判断解析出来的显示对象是否
 * 存在引用,事件等,自动资源回收.
 * 另外SWF解析的时候需要做MovieClip -> Bitmap的优化,用来降低播放压力,
 * 因为聊天区可能一下子就是几百个SWF在播放,初始化和播放都有压力
 * */
class BaseParser {

	/**
	 * 之前加载并存起来的二进制字节,可以用来渲染成实际的显示对象.
	 * */
	protected var _bytes:ByteArray = null;
	/**
	 * 渲染结果回调方法,只接受一个参数,可以是渲染对象或者错误消息和事
	 * 件等,由外部逻辑自行判断并处理,这里只负责传递.
	 * */
	protected var _onComplate:Function = null;

	/**
	 * 构造方法需要传递参数,这里看之后功能变更情况,可以考虑构造方法
	 * 不传参的方法,应该更容易实现资源池功能.
	 *
	 * @param bytes 用来解析的二进制数据
	 * @param onComplete 结果回调方法
	 * */
	public function BaseParser(bytes:ByteArray, onComplete:Function) {
		_bytes = bytes;
		_onComplate = onComplete;
		// 直接启动渲染
		parse();
	}

	/**
	 * 解析并渲染方法,主要通过不同的loader把二进制数据加载并输出成显示对象.
	 * 子类必须覆写这个方法.
	 * */
	protected function parse():void {

	}

	/**
	 * 解析并渲染完成后调用此方法,用来调用完成回调,触发外部逻辑
	 *
	 * @param data 解析出来的结果
	 * */
	protected function result(data:*):void {
		if (_onComplate != null)
			_onComplate.apply(null, [data]);
	}

	/**
	 * 异常处理方法,解析失败或者异常时调用此方法,出发外部逻辑
	 *
	 * @param data 解析异常的事件对象或者Error对象,或者自定义的消息体等
	 * */
	protected function error(data:*):void {
		if (_onComplate != null)
			_onComplate.apply(null, [data]);
	}

}

/**
 * IMAGEParse负责对二进制数据进行图片解析和渲染.
 *
 * @inheritDoc
 * */
class IMAGEParser extends BaseParser{

	/**
	 * @inheritDoc
	 * */
	public function IMAGEParser(bytes:ByteArray, onComplete:Function) {
		super(bytes, onComplete);
	}

	override protected function parse():void {
		// 图片应该用loader解析
		var loader:Loader = new Loader(),
			info:LoaderInfo = loader.contentLoaderInfo;
		// 侦听Event.COMPLETE事件
		info.addEventListener(Event.COMPLETE, function (e:Event):void {
			var display:DisplayObject = toDisplay(e.target as LoaderInfo);
			if (display is Bitmap) (display as Bitmap).smoothing = true;
			if (display)
				result(display);
		});
		// 异常事件
		info.addEventListener(IOErrorEvent.IO_ERROR, error);
		info.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
		// 加载二进制数据
		loader.loadBytes(_bytes);
	}

	/**
	 * 解析LoaderInfo.content属性并返回当前Parser需要的显示对象.
	 * IMAGEParse返回的应该是Bitmap.
	 *
	 * 可供同类型的Parse(使用loader加载)覆写.
	 *
	 * @param loaderInfo 加载对象的根属性对象
	 * */
	protected function toDisplay(loaderInfo:LoaderInfo):DisplayObject {
		if (loaderInfo) {
			return loaderInfo.content;
		}
		return null;
	}

}

/**
 * SWFParser负责对二进制数据进行MovieClip解析和渲染.
 *
 * @inheritDoc
 * */
class SWFParser extends IMAGEParser {

	/**
	 * SWF假如是用内含Class的方式,此即代表该Class的名字
	 * */
	protected var _key:String = null;

	/**
	 *
	 * @param key SWF分两种形式,一种是swf加载过来直接当显示对象渲染的,还有一种是需要
	 *            解析并提取其中的Class来处理.假如提供此参数,则认为需要使用后一种方式
	 *            处理
	 *
	 * @inheritDoc
	 * */
	public function SWFParser(bytes:ByteArray, onComplete:Function, key:String = null) {
		_key = key;
		super(bytes, onComplete);
	}

	/**
	 * @inheritDoc
	 * */
	override protected function toDisplay(loaderInfo:LoaderInfo):DisplayObject {
		if (loaderInfo) {
			if (_key) {
				// 假如需要处理Class的话
				var has:Boolean = loaderInfo.applicationDomain.hasDefinition(_key);
				var cls:Class = has ? loaderInfo.applicationDomain.getDefinition(_key) as Class : null;
				if (cls) {
					return new cls() as DisplayObject;
				}
			} else {
				// 不处理Class就直接用加载对象返回了
				return loaderInfo.content;
			}
		}
		return null;
	}

}

/**
 * GIFParser负责处理二进制数据为GIF动画.
 * 该类使用了第三方库theturtle32/Flash-Animated-GIF-Library
 * [https://github.com/theturtle32/Flash-Animated-GIF-Library],
 * 处理了源代码中两个小问题得以顺利使用和运行.
 *
 * @inheritDoc
 * */
class GIFParser extends BaseParser {

	public function GIFParser(bytes:ByteArray, onComplete:Function) {
		super(bytes, onComplete);
	}

	/**
	 * @inheritDoc
	 * */
	override protected function parse():void {
		// 使用第三方GIF库处理二进制数据解析
		var gif:GIFPlayer = new GIFPlayer();
		gif.addEventListener(
				GIFPlayerEvent.COMPLETE,
					function (e:GIFPlayerEvent):void {
						result(gif);
					});
		gif.addEventListener(AsyncDecodeErrorEvent.ASYNC_DECODE_ERROR, error);
		gif.loadBytes(_bytes);
	}

}