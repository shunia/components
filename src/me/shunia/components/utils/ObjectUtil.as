/**
 * @DATE 2015/12/22;
 * @AUTHOR qingfenghuang;
 */

package me.shunia.components.utils {
	
	public class ObjectUtil {
		
		public static function merge(original:Object, target:Object, ignoreComplexType:Boolean = true):Object {
			for (var k:String in original) {
				if (isSimpleType(original[k]))
					target[k] = original;
				else if (!ignoreComplexType)
					target[k] = merge(original[k], target.hasOwnProperty(k) ? target[k] : {});
			}
			return target;
		}

		public static function diff(original:Object, target:Object):Array {
			var df:Array = [];
			if (!original || !target) return df;

			for (var prop:String in target) {
				if (original[prop] != target[prop]) {
					df.push(prop);
				}
			}
			return df;
		}

		public static function isSimpleType(t:*):Boolean {
			return ["string", "number", "boolean"].indexOf(typeof(t)) != -1;
		}
		
	}
	
}
