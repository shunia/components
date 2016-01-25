package me.shunia.components.video
{

	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * 视频播放器的接口
	 * */
	public interface IPlayer
	{
		/**
		 * 开始播放由url指定的视频流或文件.
		 * 当url为空时代表恢复播放
		 * */
		function play(url:String = null):void;
		/**
		 * 暂停视频,需要恢复的话使用this.play();
		 * */
		function pause():void;
		/**
		 * 停止视频
		 * */
		function stop():void;
		/**
		 * 前进或后退,对rtmp视频不起作用
		 * */
		function seek(offset:int):void;
		/**
		 * 停止视频,并销毁相关资源
		 * */
		function dispose():void;
		/**
		 * 设置音量0-100
		 * */
		function set volume(value:int):void;
		/**
		 * 获取音量0-100,默认100
		 * */
		function get volume():int;
		/**
		 * 获取视频显示对象
		 * */
		function get video():Video;
		/**
		 * 设置视频的宽
		 * */
		function set width(value:Number):void;
		/**
		 * 设置视频的高
		 * */
		function set height(value:Number):void;
		/**
		 * 当前是否正在播放
		 * */
		function get playing():Boolean;
		/**
		 * 当前的视频流对象
		 * */
		function get netStream():NetStream;
		/**
		 * 当前视频流连接
		 * */
		function get netConnection():NetConnection;
	}
}