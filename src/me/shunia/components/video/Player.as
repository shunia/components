package me.shunia.components.video
{

	import flash.display.Sprite;
	import flash.media.SoundTransform;
	import flash.media.Video;

	public class Player extends Sprite implements IPlayer
	{
		
		protected var _video:Video = null;
		protected var _controller:Controller = null;
		protected var _volume:int = 100;
		protected var _isRTMP:Boolean = false;
		protected var _isPaused:Boolean = false;
		protected var _isStopped:Boolean = false;
		
		public function Player(w:int = 320, h:int = 240)
		{
			_video = new Video(w, h);
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
				default :
					dispatchEvent(new PlayerEvent(PlayerEvent.INFO, {info: status}));
					break;
			}
		}

		protected function onConnected():void {
			_video.visible = true;
			_video.attachNetStream(_controller.stream);
			volume = _volume;
		}

		protected function onStarted():void {

		}

		protected function onClosed():void {
			if (!_isStopped)
				stop();
		}

		protected function onBuffered():void {

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
					_controller.start(linkAndMountPoint[0], linkAndMountPoint[1]);
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
//			if (!_isRTMP) {
//
//			}
		}
		
		public function get playing():Boolean {
			if (_controller.connection && _controller.connection.connected) 
				return !_isStopped && !_isPaused;
			else 
				return false;
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
			if (_controller.stream) {
				var st:SoundTransform = new SoundTransform(_volume / 100);
				_controller.stream.soundTransform = st;
			}
		}
	}
}

import flash.events.AsyncErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

class Controller {

	public static const STATUS_CONNECTED:String = "status_connected";
	public static const STATUS_STARTED:String = "status_started";
	public static const STATUS_CLOSED:String = "status_closed";
	public static const STATUS_BUFFERED:String = "status_buffered";

	protected var _invoker:Function = null;
	protected var _skipInvoke:Boolean = false;
	protected var _firstBuff:Boolean = false;

	protected var _link:String = null;
	protected var _mountPoint:String = null;

	public var stream:NetStream = null;
	public var connection:NetConnection = null;

	public function Controller(invoker:Function) {
		_invoker = invoker;
		connection = new NetConnection();
		connection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
		connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
		connection.addEventListener(IOErrorEvent.IO_ERROR, onError);
		connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		connection.client = {};
	}

	public function start(link:String = null, mountPoint:String = null):void {
		_link = link;
		_mountPoint = mountPoint;

		invoke([_link, _mountPoint].join(","));

		stopConnection();
		connection.connect(_link);
	}

	public function stop(dispose:Boolean = false):void {
		stopConnection();
		stopStream(dispose);
	}

	protected function stopConnection():void {
		if (connection.connected) {
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
				initStream();
				invoke(STATUS_CONNECTED);
				break;
			default :
				// NetConnection断了的话重试
				initStream();
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
		}
	}

	protected function initStream():void {
		stopStream(true);
		_firstBuff = false;

		if (!stream) stream = new NetStream(connection);
//		stream.useHardwareDecoder = true;		// 硬件解码
//		stream.bufferTime = 3;					// 3秒缓冲
		stream.client = {};

		stream.addEventListener(NetStatusEvent.NET_STATUS, onStreamStatus);
		stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
		stream.addEventListener(IOErrorEvent.IO_ERROR, onError);

		stream.play(_mountPoint);
	}

	protected function invoke(status:String):void {
		if (status && _invoker != null)
			_invoker.apply(null, [status]);
	}

	protected function onError(e:*):void {
		invoke(e.message);
	}
}