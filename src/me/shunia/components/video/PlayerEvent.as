/**
 * Created by qingfenghuang on 2015/12/11.
 */
package me.shunia.components.video {

	import flash.events.Event;

	public class PlayerEvent extends Event{

        public static const INFO:String = "info";

        public var info:String = "";

        public function PlayerEvent(type:String, args:Object = null) {
            super(type);

            if (args) {
                for (var k:String in args) {
                    if (this.hasOwnProperty(k))
                        this[k] = args[k];
                }
            }
        }

    }
}
