package me.shunia.components.video
{

	import flash.display.Sprite;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class Player extends Sprite implements IPlayer
	{

		public static const MODE_PLAY:String = "play";
		public static const MODE_PUBLISH:String = "publish";

		protected var _video:Video = null;
		protected var _controller:Controller = null;
		protected var _volume:int = 100;
		protected var _isRTMP:Boolean = false;
		protected var _isPaused:Boolean = false;
		protected var _isStopped:Boolean = false;
		protected var _mode:String = MODE_PLAY;

		public function Player(w:int = 320, h:int = 240)
		{
			_video = new Video(w, h);
			_video.smoothing = true;
			addChild(_video);
			_controller = new Controller(infoHandler);
		}

		protected function infoHandler(status:String):void {
			switch (status) {
				case Controller.STATUS_CONNECTED :
					onConnected();
					break;
				case Controller.STATUS_STARTED :
					onStarted();
					break;
				case Controller.STATUS_BUFFERED :
					onBuffered();
					break;
				case Controller.STATUS_CLOSED :
					onClosed();
					break;
				case Controller.STATUS_PUBLISHED :
					onPublishded();
					break;
				default :
					dispatchEvent(new PlayerEvent(PlayerEvent.INFO, {info: status}));
					break;
			}
		}

		protected function onConnected():void {
			if (_mode == MODE_PLAY) {
				_video.visible = true;
				_video.attachNetStream(_controller.stream);
			}
		}

		protected function onStarted():void {
			if (_mode == MODE_PLAY) {
				volume = _volume;
			}
		}

		protected function onClosed():void {
			if (!_isStopped)
				stop();
		}

		protected function onBuffered():void {

		}

		protected function onPublishded():void {

		}

		public function dispose():void {
			_video.visible = false;
			_controller.stop(true);
			_video.attachNetStream(null);
			_isStopped = true;
		}

		public function pause():void {
			if (playing) {
				_isPaused = true;
				if (_controller.stream)
					_controller.stream.pause();
			}
		}

		public function play(url:String = null):void {
			_mode = MODE_PLAY;
			init(url);
		}

		public function publish(url:String = null):void {
			_mode = MODE_PUBLISH;
			init(url);
		}

		protected function init(url:String):void {
			if (url && url.length) {
				// 如果正在播,先停止
				if (playing)
					dispose();
				// 更新标记
				_isRTMP = url.substr(0, 7).toLowerCase() === "rtmp://";
				_isPaused = false;
				_isStopped = false;

				var linkAndMountPoint:Array = splitPlayURL(url, _isRTMP);
				if (linkAndMountPoint && linkAndMountPoint.length)
				// 启动播放
					_controller.start(linkAndMountPoint[0], linkAndMountPoint[1], mode == MODE_PUBLISH);
			} else if (_isPaused) {
				if (_controller.stream)
					_controller.stream.resume();
				_isPaused = false;
			}
		}

		protected function splitPlayURL(url:String, isRTMP:Boolean):Array {
			if (isRTMP) {
				var i:int = url.lastIndexOf("/");
				if (i != -1)
					return [url.substring(0, i), url.substring(i + 1, url.length)];
			} else
				return [null, url];

			return null;
		}

		public function seek(offset:int):void {
			if (mode == MODE_PUBLISH) return;
			if (_isRTMP) return;
		}

		public function get playing():Boolean {
			if (_controller.connection && _controller.connection.connected)
				return !_isStopped && !_isPaused;
			else
				return false;
		}

		public function get mode():String {
			return _mode;
		}

		public function stop():void {
			if (playing) {
				_controller.stop(false);
			}
			_isStopped = true;
		}

		public function get video():Video {
			return _video;
		}

		override public function set width(value:Number):void {
			_video.width = value;
		}

		override public function set height(value:Number):void {
			_video.height = value;
		}

		public function get volume():int {
			return _volume;
		}

		public function set volume(value:int):void {
			_volume = value;
			if (_controller.stream && _mode == MODE_PLAY) {
				var st:SoundTransform = new SoundTransform(_volume / 100);
				_controller.stream.soundTransform = st;
			}
		}

		public function get netStream():NetStream {
			return _controller.stream;
		}

		public function get netConnection():NetConnection {
			return _controller.connection;
		}
	}
}

import flash.events.AsyncErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.ObjectEncoding;

class Controller {

	public static const STATUS_CONNECTED:String = "status_connected";
	public static const STATUS_STARTED:String = "status_started";
	public static const STATUS_CLOSED:String = "status_closed";
	public static const STATUS_BUFFERED:String = "status_buffered";
	public static const STATUS_PUBLISHED:String = "status_published";

	protected var _invoker:Function = null;
	protected var _skipInvoke:Boolean = false;
	protected var _firstBuff:Boolean = false;

	protected var _link:String = null;
	protected var _mountPoint:String = null;
	protected var _publish:Boolean = false;

	public var stream:NetStream = null;
	public var connection:NetConnection = null;

	public function Controller(invoker:Function) {
		_invoker = invoker;
	}

	protected function initConnection():void {
		connection = new NetConnection();
		connection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
		connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
		connection.addEventListener(IOErrorEvent.IO_ERROR, onError);
		connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		connection.client = {};

		// 为了兼容内网srs系统
		connection.objectEncoding = ObjectEncoding.AMF0;

		connection.connect(_link);
	}

	/**
	 * 启动Controler.
	 *
	 * @param link
	 * @param mountPoint
	 * @param publish
	 * */
	public function start(link:String = null, mountPoint:String = null, publish:Boolean = false):void {
		_link = link;
		_mountPoint = mountPoint;
		_publish = publish;

		invoke([_link, _mountPoint].join(","));

		stopConnection();
		initConnection();
	}

	public function stop(dispose:Boolean = false):void {
		stopConnection();
		stopStream(dispose);
	}

	protected function stopConnection():void {
		if (connection && connection.connected) {
			_skipInvoke = true;
			connection.close();
		}
	}

	protected function stopStream(dispose:Boolean = false):void {
		if (stream) {
			stream.removeEventListener(NetStatusEvent.NET_STATUS, onStreamStatus);
			stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, onError);

			try {
				if (dispose) {
					stream.dispose();
				} else {
					stream.close();
				}
				stream = null;
			} catch (e:Error) {}
		}
	}

	protected function onConnectionStatus(e:NetStatusEvent):void {
		invoke(e.info.code);

		if (_skipInvoke) {
			_skipInvoke = false;
			return;
		}

		switch (e.info.code) {
			case "NetConnection.Connect.Success" :
				if (!connection.connected) {
					connection.connect(_link);
				} else {
					initStream();
					invoke(STATUS_CONNECTED);

					// 根据推拉流标记决定是拉流还是推流
					if (_publish) {
						stream.publish(_mountPoint);
					} else {
						stream.play(_mountPoint);
					}
				}
				break;
			default :
				// NetConnection断了的话重试
				stopConnection();
				initConnection();
				break;
		}
	}

	protected function onStreamStatus(e:NetStatusEvent):void {
		invoke(e.info.code);

		if (_skipInvoke) {
			_skipInvoke = false;
			return;
		}

		switch (e.info.code) {
			case "NetStream.Play.Start" :
				invoke(STATUS_STARTED);
				break;

			case "NetStream.Buffer.Full" :
				if (!_firstBuff) _firstBuff = true;
				if (_firstBuff)
					invoke(STATUS_BUFFERED);
				break;

			case "NetStream.Publish.Start" :
				invoke(STATUS_PUBLISHED);
				break;
		}
	}

	protected function initStream():void {
		stopStream(true);
		_firstBuff = false;

		stream = new NetStream(connection);
//		stream.useHardwareDecoder = true;		// 硬件解码
//		stream.bufferTime = 3;					// 3秒缓冲
		stream.client = {};

		stream.addEventListener(NetStatusEvent.NET_STATUS, onStreamStatus);
		stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
		stream.addEventListener(IOErrorEvent.IO_ERROR, onError);
	}

	protected function invoke(status:String):void {
		if (status && _invoker != null)
			_invoker.apply(null, [status]);
	}

	protected function onError(e:*):void {
		invoke(e.message);
	}
}