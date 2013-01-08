package edu.cmu.monsterstem.objects {
	import edu.cmu.monsterstem.objects.parts.MonsterPart;
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.core.CitrusEngine;
	
	/**
	 * ...
	 * @author Erik Harpstead
	 */
	public class MonsterGenerator extends CitrusObject {
		private static var types:Array = new Array("cat", "lizard", "rock", "slime", "bat");
		
		public static function randomType():String {
			return randomElement(types);
		}
		
		private static function randomElement(target:Array):* {
			var dex:int = Math.round(Math.random() * target.length);
			trace(dex);
			return target[dex];
		}
		
		private static var counter:int = 0;
		
		private static function makeName():String {
			counter++;
			if (counter < 10)
				return "monster00" + counter;
			else if (counter < 100)
				return "monster0" + counter;
			else 
				return "monster" + counter;
		}
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _maxMonsters:Number = 3;
		
		[Property(value="3")]
		public function set maxMonsters(value:Number):void {
			_maxMonsters = value;
		}
		
		public function get maxMonsters():Number {
			return _maxMonsters;
		}
		
		[Property(value="0")]
		public function set x(value:Number):void {
			_x = value;
		}
		
		public function get x():Number {
			return _x;
		}
		
		[Property(value="0")]
		public function set y(value:Number):void {
			_y = value;
		}
		
		public function get y():Number {
			return _y;
		}
		
		[Property(value="10")]
		public function set width(value:Number):void {
			_width = value;
		}
		
		public function get width():Number {
			return _width;
		}
		
		[Property(value="10")]
		public function set height(value:Number):void {
			_height = value;
		}
		
		public function get height():Number {
			return _height;
		}
		
		[Property(value="", browse="true")]
		public function set armsFrontView(value:*):void {
			//MonsterPart.armFrontSwf = value;
		}
		
		public function get armsFrontView():* {
			return MonsterPart.armFrontSwf;
		}
		
		[Property(value="",browse="true")]
		public function set armsBackView(value:*):void {
			//MonsterPart.armBackSwf = value;
		}
		
		public function get armsBackView():* {
			return MonsterPart.armBackSwf;
		}
		
		[Property(value="",browse="true")]
		public function set bodyView(value:*):void {
			//MonsterPart.bodySwf = value;
		}
		
		public function get bodyView():* {
			return MonsterPart.bodySwf;
		}
		
		[Property(value="",browse="true")]
		public function set legView(value:*):void {
			//MonsterPart.legSwf = value;
		}
		
		public function get legView():* {
			return MonsterPart.legSwf;
		}
		
		
		public function Make(name:String, x:Number, y:Number, width:Number, height:Number):MonsterGenerator {
			return new MonsterGenerator(name, { x: x, y: y, width: width, height: height});
		}
		
		public function MonsterGenerator(name:String, params:Object) {
			super(name, params);
		}
		
		public function spawnMonster():void {
			if (counter >= _maxMonsters)
				return;
			var m:Monster = Monster.Make(makeName(), x, y, width, height);
			m.initParts();
			CitrusEngine.getInstance().state.add(m);
		}
	}

}