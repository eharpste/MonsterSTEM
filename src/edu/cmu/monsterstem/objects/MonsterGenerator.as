package edu.cmu.monsterstem.objects {
	/**
	 * ...
	 * @author Erik Harpstead
	 */
	public class MonsterGenerator {
		private var heads:Array = new Array("spike", "horn", "fluffy", "bald");
		private var arms:Array = new Array("robot", "hammer", "tentacle", "stick");
		private var legs:Array = new Array("normal", "fast", "springy", "climb");
		private var misc:Array = new Array("fire", "lightning", "wings", "ice");
		
		
		public function MonsterGenerator() {
			
		}
		
		
		public function generateMonster():Object {
			
		}
		
		private function randomElement(target:Array):* {
			return target[Math.round(Math.random() * target.length)];
		}
	}

}