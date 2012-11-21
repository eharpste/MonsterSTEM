package 
{
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.PhysicsObject;
	import com.citrusengine.objects.platformer.Baddy;
	import com.citrusengine.objects.platformer.Coin;
	import com.citrusengine.objects.platformer.Crate;
	import com.citrusengine.objects.platformer.Hero;
	import com.citrusengine.objects.platformer.Missile;
	import com.citrusengine.objects.platformer.MovingPlatform;
	import com.citrusengine.objects.platformer.Platform;
	import com.citrusengine.objects.platformer.RewardBox;
	import com.citrusengine.objects.platformer.Sensor;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import edu.cmu.monsterstem.state.ExampleState;
	import edu.cmu.monsterstem.state.GoldSpikeState;
	import edu.cmu.monsterstem.objects.Monster;
	import edu.cmu.monsterstem.objects.TaggedSensor
	import edu.cmu.monsterstem.objects.MonsterGenerator;
	
	public class Main extends CitrusEngine {
		public var instructionText:TextField;
		private var levelNames:Array = new Array("example", "levelone","goldspike");
		private var levelClasses:Array = new Array(ExampleState, ExampleState,GoldSpikeState);
		private var levelXMLs:Vector.<XML>;
		private var currentLevel:int = 0;
		
		
		public function Main():void 
		{
			super();
			
			var classes:Array = [Baddy, CitrusSprite, Coin, Crate, Hero, Missile, MovingPlatform, PhysicsObject, Platform, RewardBox, Sensor, Monster,MonsterGenerator];
			//console.openKey = Keyboard.F1; 
			console.addCommand("load", handlePlayCommand);
			console.addCommand("play", handlePlayCommand);
			console.addCommand("list", handleListCommand);
			console.addCommand("ls", handleListCommand);
			console.addCommand("clear", handleClearCommand);
			console.addCommand("cls", handleClearCommand);
			console.addCommand("debug", handleDebugCommand);
			
			displayText("Press tab to open the console. Then type 'play levelName' where levelName is the name of the level file you made.\nFrom the console, you can use the up/down arrow keys to quickly access your previous commands.");
			displayText("\n\nWhile in a level, you can turn the 'debug graphics' on and off by using this command: 'set Box2D visible true'",true);
			levelXMLs = new Vector.<XML>(levelNames.length,true);
			
			for each (var lev:String in levelNames) {
				var l:URLLoader = new URLLoader();
				l.addEventListener(Event.COMPLETE, handleLevelLoadComplete);
				l.addEventListener(IOErrorEvent.IO_ERROR, handleLevelLoadError);
				
				if (lev.indexOf(".lev") == -1)
					lev += ".lev";
				
				l.load(new URLRequest(lev));
			}
		}
		
		private function handlePlayCommand(level:String):void {
			var check:int = levelNames.indexOf(level.toLowerCase());
			if (check == -1) {
				displayText("The level you typed does not exist. Please check the file name and try again." +
				"\nIf your level is in a subdirectory relative to this SWF, you will need to specify that directory in the command." +
				"\nFor example: 'play levels/level1'");
				return;
			}
			else {
				clearText();
				currentLevel = check;
				state = new levelClasses[check](levelXMLs[check]);
			}
		}
		
		private function handleLevelLoadComplete(e:Event):void {
			var lvlXML:XML = new XML(e.target.data);
			var n:String = lvlXML.@name;
			levelXMLs[levelNames.indexOf(n.toLowerCase())] = lvlXML;
		}
		
		private function handleLevelLoadError(e:IOErrorEvent):void  {
			displayText("level load error: " + e.target.url);
		}
		
		private function handleListCommand(arg:String):void {
			switch(arg) {
				case "levels" :
				case "lvls" :
					var op:String = "Available Levels:\n";
					for each (var s:String in levelNames) {
						op += s + "\n";
					}
					displayText(op);
					break;
				case "objects" :
				case "obs" :
					if (state) {
						var obs:String = "Available Objects:\n";
						for each (var co:CitrusObject in state.getObjectsByType(CitrusObject)) {
							obs += co.name + "\n";
						}
						displayText(obs);
					}
					break;
				default :
					return;
			}
			return;
		}
		
		private function handleClearCommand():void {
			clearText();
		}
		
		private function handleDebugCommand(arg:String):void {
			if (arg == "true")
				debug = true;
			else if (arg == "false")
				debug = false;
		}
		
		public function displayText(message:String, append:Boolean = false):void {
			if (!instructionText) {
				createInstructionText();
				instructionText.text = message;
			}
			else if (append) {
				instructionText.appendText(message);
			} 
			else {
				instructionText.text = message;
			}
		}
		
		public function clearText():void {
			if (instructionText && instructionText.parent)
				removeChild(instructionText);
			instructionText = null;
		}
 		
		private function createInstructionText():void {
			instructionText = new TextField();
			addChild(instructionText);
			instructionText.autoSize = "left";
			instructionText.x = 10;
			instructionText.y = 30;
			instructionText.defaultTextFormat = new TextFormat("_sans");
		}
	}
	
}