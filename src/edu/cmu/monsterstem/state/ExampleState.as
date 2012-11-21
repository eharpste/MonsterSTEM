package  edu.cmu.monsterstem.state 
{
	import Box2D.Dynamics.Contacts.b2Contact;
	import com.citrusengine.core.State;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.platformer.box2d.Hero;
	import com.citrusengine.objects.platformer.box2d.Sensor;
	import com.citrusengine.physics.box2d.Box2D;
	import com.citrusengine.utils.ObjectMaker2D;
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.view.ISpriteView;
	import com.citrusengine.objects.Box2DPhysicsObject;
	
	public class ExampleState extends State
	{
		private var _levelData:XML;
		private var _hero:Hero;
		private var _resetSensor:Sensor;
		
		public function ExampleState(levelData:XML) 
		{
			//This is the level XML file that was generated by the Level Architect.
			_levelData = levelData;
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			//Create Box2D
			var box2D:Box2D = new Box2D("Box2D");
			add(box2D);
			
		//	box2D.visible = true;
			
			//Create the level objects from the XML file.
			if (_levelData)
				ObjectMaker2D.FromLevelArchitect(_levelData);
			
			//Find the hero object, and make it the camera target if it exists.
			_hero = getFirstObjectByType(Hero) as Hero;
			if (_hero)
			{
				view.cameraTarget = _hero;
				view.cameraOffset = new MathVector(stage.stageWidth / 2, stage.stageHeight / 2);
				view.cameraEasing = new MathVector(0.4, 0.4);
			}
			
			_resetSensor = getObjectByName("resetSensor") as Sensor;
			if(_resetSensor) {
				_resetSensor.onBeginContact.add(resetLevel);
				trace(typeof(_resetSensor.view));
			}
			
			for each (var co:CitrusObject in getObjectsByType(CitrusObject)) {
				trace(co.name + " : " + (co is ISpriteView ? (co as ISpriteView).view : "")+"\n");
			}
		}
		
		private function resetLevel(contact:b2Contact):void {
			var other:Box2DPhysicsObject =  Box2DPhysicsObject.CollisionGetOther(_resetSensor, contact);
			if (other is Hero) {
				CitrusEngine.getInstance().state = new ExampleState(_levelData);
			}
		}
	}

}