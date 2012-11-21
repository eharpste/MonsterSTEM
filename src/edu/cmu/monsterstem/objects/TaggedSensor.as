package edu.cmu.monsterstem.objects {
	import com.citrusengine.objects.platformer.Sensor;
	
	/**
	 * ...
	 * @author Erik Harpstead
	 */
	public class TaggedSensor extends Sensor {
		private var _tag:String;
		
		public function set tag(value:String):void {
			_tag = value;
		}
		
		public function get tag():String {
			return _tag;
		}
		
		public function TaggedSensor() {
			super();
		}
		
	}

}