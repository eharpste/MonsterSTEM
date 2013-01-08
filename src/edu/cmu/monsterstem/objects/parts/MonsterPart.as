package edu.cmu.monsterstem.objects.parts 
{
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.view.ISpriteView;
	import edu.cmu.monsterstem.objects.Monster;
	import edu.cmu.monsterstem.objects.MonsterGenerator;
	import flash.display.MovieClip;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Erik Harpstead
	 */
	public class MonsterPart extends CitrusObject implements ISpriteView{
		
		/*[Embed(source = "/./art/Patch_legs.swf")]
		[Bindable]
		public static var legSwf:Class;/**/
		public static var legSwf:String = "./art/Patch_legs.swf";
		//public static var legSwf:*;
		
		/*[Embed(source = "/./art/Patch_armFront.swf")]
		[Bindable]
		public static var armFrontSwf:Class;/**/
		public static var armFrontSwf:String = "./art/Patch_armFront.swf";
		//public static var armFrontSwf:*;
		
		/*[Embed(source = "/./art/Patch_armBack.swf")]
		[Bindable]
		public static var armBackSwf:Class;/**/
		public static var armBackSwf:String = "./art/Patch_armBack.swf";
		//public static var armBackSwf:*;
		
		/*[Embed(source = "/./art/Patch_body.swf")]
		[Bindable]
		public static var bodySwf:Class;/**/
		public static var bodySwf:String = "./art/Patch_body.swf";
		//public static var bodySwf:*;
		
		private var _parent:Monster;
		
		private var _x:Number;
		private var _y:Number;
		private var _height:Number;
		private var _width:Number;
		private var _parallax:Number;
		private var _rotation:Number;
		private var _group:Number;
		private var _visible:Boolean;
		private var _view:*;
		private var _animation:String;
		private var _inverted:Boolean;
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _registration:String;
		private var _species:String;
		
		public var onAnimationChange:Signal;
		
		public function set species(value:String):void {
			_species = value;
		}
		
		public function get species():String {
			return _species;
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
		
		public function get z():Number {
			return 0;
		}
		
		public function get depth():Number {
			return 0;
		}
		
		[Property(value="0")]
		public function set width(value:Number):void {
			_width = value;
		}
		
		public function get width():Number {
			return _width;
		}
		
		[Property(value="0")]
		public function set height(value:Number):void {
			_height = value;
		}
		
		public function get height():Number {
			return _height;
		}
		
		[Property(value="1")]
		public function set parallax(value:Number):void {
			_parallax = value;
		}
		
		public function get parallax():Number {
			return _parallax;
		}
		
		[Property(value="0")]
		public function set rotation(value:Number):void {
			_rotation = value;
		}
		
		public function get rotation():Number {
			return _rotation;
		}
		
		[Property(value = "0")]
		public function set group(value:Number):void {
			_group = value;
		}
		
		public function get group():Number {
			return _group;
		}
		
		public function set visible(value:Boolean):void {
			_visible = value;
		}
		
		public function get visible():Boolean {
			return _visible;
		}
		
		[Property(value="", browse="true")]
		public function set view(value:*):void {
			_view = value;
		}
		
		public function get view():* {
			return _view;
		}
		
		public function get animation():String {
			return _animation;
		}
		
		public function get inverted():Boolean {
			return _inverted;
		}
		
		[Property(value="0")]
		public function set offsetX(value:Number):void {
			_offsetX = value;
		}
		
		public function get offsetX():Number {
			return _offsetX;
		}
		
		[Property(value="0")]
		public function set offsetY(value:Number):void {
			_offsetY = value;
		}
		
		public function get offsetY():Number {
			return _offsetY;
		}
		
		[Property(value="center")]
		public function set registration(value:String):void {
			_registration = value;
		}
		
		public function get registration():String {
			return _registration;
		}
		
		public function set parent(p:Monster):void {
			_parent = p;
			_parent.onAnimationChange.add(handleAnimationChange);
			this.parallax = _parent.parallax;
			this.group = _parent.group;
			this.offsetX = _parent.offsetX;
			this.offsetY = _parent.offsetY;
			syncToParent();
		}
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, view:* = null, type:String="bat"):MonsterPart {
			if (view == null) view = MovieClip;
			return new MonsterPart(name, { x: x, y: y, width: width, height: height, view: view, type: type} );
		}
		
		public static function MakeLegs(name:String, x:Number, y:Number, width:Number, height:Number, type:String = "bat"):MonsterPart {
			return Make(name, x, y, width, height, legSwf,type);
		}
		
		public static function RandomLegs(name:String, x:Number, y:Number, width:Number, height:Number):MonsterPart {
			return Make(name, x, y, width, height, legSwf, MonsterGenerator.randomType());
		}
		
		public static function MakeFrontArm(name:String, x:Number, y:Number, width:Number, height:Number, type:String = "bat"):MonsterPart {
			return Make(name, x, y, width, height, armFrontSwf);
		}
		
		public static function RandomFrontArm(name:String, x:Number, y:Number, width:Number, height:Number):MonsterPart {
			return Make(name, x, y, width, height, armFrontSwf, MonsterGenerator.randomType());
		}
		
		public static function MakeBackArm(name:String, x:Number, y:Number, width:Number, height:Number, type:String = "bat"):MonsterPart {
			return Make(name, x, y, width, height, armBackSwf);
		}
		
		public static function RandomBackArm(name:String, x:Number, y:Number, width:Number, height:Number):MonsterPart {
			return Make(name, x, y, width, height, armBackSwf, MonsterGenerator.randomType());
		}
		
		public static function MakeBody(name:String, x:Number, y:Number, width:Number, height:Number, type:String = "bat"):MonsterPart {
			return Make(name, x, y, width, height, bodySwf);
		}
		
		public static function RandomBody(name:String, x:Number, y:Number, width:Number, height:Number):MonsterPart {
			return Make(name, x, y, width, height, bodySwf, MonsterGenerator.randomType());
		}
		
		/*public static function Duplicate(master:MonsterPart):MonsterPart {
			var view:* = master.view
		}*/
		
		public function MonsterPart(name:String, params:Object)  {
			super(name, params);
			
			onAnimationChange = new Signal();
		}
		
		private function syncToParent():void {
			this.x = _parent.x;
			this.y = _parent.y;
			this.rotation = _parent.rotation;
			this._inverted = _parent.inverted;
			//CitrusEngine.dbg("view is: " + view, this,"viewcheck");
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			if(_parent)
				syncToParent();
		}
		
		private function handleAnimationChange():void {
			_animation = species + "-" + _parent.animation;
			trace("animation: " + _animation);
			onAnimationChange.dispatch();
		}
		
		public function getBody():* {
			return _parent.getBody();
		}
		
		override public function destroy():void {
			_parent = null;
			super.destroy();
		}
	}
}