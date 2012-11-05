package edu.cmu.monsterstem.objects.parts 
{
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.view.ISpriteView;
	import edu.cmu.monsterstem.objects.Monster;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Erik Harpstead
	 */
	public class MonsterPart extends CitrusObject implements ISpriteView{
		private var _parent:Monster;
		private var frames:Array;
		
		
		private var _x:Number;
		private var _y:Number;
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
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, view:* = null):MonsterPart {
			if (view == null) view = MovieClip;
			return new MonsterPart(name, { x: x, y: y, width: width, height: height, view: view } );
		}
		
		public function MonsterPart(name:String, params:Object)  {
			super(name, params);
			if (view is MovieClip) {
				frames = (view as MovieClip).currentLabels;
			}
		}
		
		private function syncToParent():void {
			this.x = _parent.x;
			this.y = _parent.y;
			this.rotation = _parent.rotation;
			this._inverted = _parent.inverted;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			syncToParent();
		}
		
		private function handleAnimationChange(newAnimation:String):void {
			if (frames.indexOf(newAnimation) == -1) {
				newAnimation = "default";
			}
			_animation = newAnimation;
		}
	}
}