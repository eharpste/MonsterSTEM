package edu.cmu.monsterstem.objects 
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Fixture;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.objects.platformer.box2d.Enemy;
	import com.citrusengine.objects.platformer.box2d.Platform;
	import com.citrusengine.objects.platformer.box2d.Crate;
	import com.citrusengine.utils.Box2DShapeMaker;
	import edu.cmu.monsterstem.objects.parts.MonsterPart;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import org.osflash.signals.Signal;
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.physics.PhysicsCollisionCategories;
	import flash.geom.Point;
	
	/**
	 * This is the main class for Monsters, its starting as a copy of the Hero
	 * class that is included in the platformer citrus library. We only need
	 * some of that functionality so I'm stripping out what isn't necessary
	 * and allowing for adding new functionality that could allow the monsters
	 * to activate themselves. I'm wrestling with how to do the rendering 
	 * because I basically want this thing to be invisible and have the parts do
	 * the actual animation.
	 * @author Erik Harpstead
	 */
	public class Monster extends Box2DPhysicsObject {
		private var legs:MonsterPart;
		private var armf:MonsterPart;
		private var armb:MonsterPart;
		private var head:MonsterPart;
		//private var misc:MonsterPart;
		
		public static const RIGHT:b2Vec2 = new b2Vec2(1, 0);
		public static const LEFT:b2Vec2 = new b2Vec2( -1, 0);
		public static const UP:b2Vec2 = new b2Vec2(0, 1);
		public static const DOWN:b2Vec2 = new b2Vec2(0, -1);
		
		//properties
		/**
		 * This is the rate at which the hero speeds up when you move him left and right. 
		 */
		[Property(value="1")]
		public var acceleration:Number = 1;
		
		/**
		 * This is the fastest speed that the hero can move left or right. 
		 */
		[Property(value="8")]
		public var maxVelocity:Number = 8;
		
		/**
		 * This is the initial velocity that the hero will move at when he jumps.
		 */
		[Property(value="14")]
		public var jumpHeight:Number = 14;
		
		/**
		 * This is the amount of "float" that the hero has when the player holds the jump button while jumping. 
		 */
		[Property(value="0.9")]
		public var jumpAcceleration:Number = 0.9;
		
		/**
		 * This is the y velocity that the hero must be travelling in order to kill a Baddy.
		 */
		[Property(value="3")]
		public var killVelocity:Number = 3;
		
		/**
		 * The y velocity that the hero will spring when he kills an enemy. 
		 */
		[Property(value="10")]
		public var enemySpringHeight:Number = 10;
		
		/**
		 * The y velocity that the hero will spring when he kills an enemy while pressing the jump button. 
		 */
		[Property(value="12")]
		public var enemySpringJumpHeight:Number = 12;
		
		/**
		 * How long the hero is in hurt mode for. 
		 */
		[Property(value="1000")]
		public var hurtDuration:Number = 1000;
		
		/**
		 * The amount of kick-back that the hero jumps when he gets hurt. 
		 */
		[Property(value="6")]
		public var hurtVelocityX:Number = 6;
		
		/**
		 * The amount of kick-back that the hero jumps when he gets hurt. 
		 */
		[Property(value="10")]
		public var hurtVelocityY:Number = 10;
		
		/**
		 * Determines whether or not the hero's ducking ability is enabled.
		 */
		[Property(value="true")]
		public var canDuck:Boolean = true;
		
		
		
		//events
		/**
		 * Dispatched whenever the hero jumps. 
		 */
		public var onJump:Signal;
		
		/**
		 * Dispatched whenever the hero gives damage to an enemy. 
		 */		
		public var onGiveDamage:Signal;
		
		/**
		 * Dispatched whenever the hero takes damage from an enemy. 
		 */		
		public var onTakeDamage:Signal;
		
		
		
		/**
		 * Dispatched whenever the hero's animation changes. 
		 */		
		public var onAnimationChange:Signal;
		
		protected var _groundContacts:Array = [];//Used to determine if he's on ground or not.
		protected var _enemyClass:Class = Enemy;
		protected var _onGround:Boolean = false;
		protected var _springOffEnemy:Number = -1;
		protected var _hurtTimeoutID:Number;
		protected var _hurt:Boolean = false;
		protected var _friction:Number = 0.75;
		//protected var _playerMovingHero:Boolean = false;
		//protected var _controlsEnabled:Boolean = true;
		//protected var _ducking:Boolean = false;
		protected var _combinedGroundAngle:Number = 0;
		protected var _walking:Boolean = false;
		protected var _walkingDirection:b2Vec2 = RIGHT;
		protected var _jumping:Boolean = false;
		protected var _active:Boolean = true;
		
		private var paramsMaster:Object;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number):Monster {
			return new Monster(name, { x: x, y: y, width: width, height: height} );
		}
		
		/**
		 * Creates a new hero object.
		 */		
		public function Monster(name:String, params:Object = null) {
			super(name, params);
			view = null;

			_animation = "default";
			paramsMaster = params;
			delete paramsMaster[view];
			
			onJump = new Signal();
			onGiveDamage = new Signal();
			onTakeDamage = new Signal();
			onAnimationChange = new Signal();		
		}
		
		public function initParts():void {
			legs = MonsterPart.RandomLegs(name + "_legs", x, y, width, height);
			armb = MonsterPart.RandomBackArm(name + "_armb", x, y, width, height);
			armf = MonsterPart.RandomFrontArm(name + "_armf", x, y, width, height);
			head = MonsterPart.RandomBody(name + "_body", x, y, width, height);
			
			legs.parent = this;
			armb.parent = this;
			armf.parent = this;
			head.parent = this;
			
			_ce.state.add(legs);
			_ce.state.add(armb);
			_ce.state.add(armf);
			_ce.state.add(head);
		}
		
		override public function destroy():void {
			clearTimeout(_hurtTimeoutID);
			onJump.removeAll();
			onGiveDamage.removeAll();
			onTakeDamage.removeAll();
			onAnimationChange.removeAll();
			
			super.destroy();
		}
		
		/**
		 * Whether or not the player can move and jump with the hero. 
		 */	
		/*public function get controlsEnabled():Boolean {
			return _controlsEnabled;
		}
		
		public function set controlsEnabled(value:Boolean):void {
			_controlsEnabled = value;
			
			if (!_controlsEnabled)
				_fixture.SetFriction(_friction);
		}*/
		
		public function get active():Boolean {
			return _active;
		}
		
		public function set active(value:Boolean):void {
			_active = value;
			
			if (!_active) {
				_fixture.SetFriction(_friction);
			}
		}
		
		
		public function get walking():Boolean {
			return _walking;
		}
		
		public function set walking(value:Boolean):void {
			_walking = value;
			
			if (!_walking) {
				_fixture.SetFriction(_friction);
			}
		}
		
		public function get walkingDirection():b2Vec2 {
			if (_walkingDirection.x >= 0)
				return RIGHT;
			else {
				return LEFT;
			}
		}
		
		/**
		 * Returns true if the hero is on the ground and can jump. 
		 */		
		public function get onGround():Boolean {
			return _onGround;
		}
		
		/**
		 * The Hero uses the enemyClass parameter to know who he can kill (and who can kill him).
		 * Use this setter to to pass in which base class the hero's enemy should be, in String form
		 * or Object notation.
		 * For example, if you want to set the "Baddy" class as your hero's enemy, pass
		 * "com.citrusengine.objects.platformer.Baddy", or Baddy (with no quotes). Only String
		 * form will work when creating objects via a level editor.
		 */
		[Property(value="com.citrusengine.objects.platformer.Baddy")]
		public function set enemyClass(value:*):void {
			if (value is String)
				_enemyClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_enemyClass = value;
		}
		
		/**
		 * This is the amount of friction that the hero will have. Its value is multiplied against the
		 * friction value of other physics objects.
		 */	
		public function get friction():Number {
			return _friction;
		}
		
		[Property(value="0.75")]
		public function set friction(value:Number):void {
			_friction = value;
			
			if (_fixture) {
				_fixture.SetFriction(_friction);
			}
		}
		
		
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
			//if the monster is active, we'll see if active is really a thing or not.
			if (_active) {
				
				//if it is being told to walk
				if (_walking) {
					//if the walking direction is to the right add to the velocity.
					if(_walkingDirection.x >= 0) {
						velocity.Add(getSlopeBasedMoveAngle());
					}
					
					//otherwise if the walking direction to the left subtract from the velocity.
					else if (_walkingDirection.x < 0) {
						velocity.Subtract(getSlopeBasedMoveAngle());
					}
				}
				
				//if they are jumping then jump
				//note this jumping variable should be set elsewhere
				//basically set it to true when they are told to jump and they will next tick
				//then set it to false when they touch the ground.
				if (_jumping) {
					if(_onGround) {
						velocity.y = -jumpHeight;
						onJump.dispatch();
					}
					else if (velocity.y < 0) {
						velocity.y -= jumpAcceleration;
					}
				}
				
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
				
				//update physics with new velocity
				_body.SetLinearVelocity(velocity);
			}
			
			
			/*
			 * This is old code borrowed from the Hero class in the standard setits not actually used.
			if (controlsEnabled) {
				var moveKeyPressed:Boolean = false;
				
				_ducking = (_ce.input.isDown(Keyboard.DOWN) && _onGround && canDuck);
				
				
				if (_springOffEnemy != -1) {
					if (_ce.input.isDown(Keyboard.SPACE))
						velocity.y = -enemySpringJumpHeight;
					else
						velocity.y = -enemySpringHeight;
					_springOffEnemy = -1;
				}
				
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
				
				//update physics with new velocity
				_body.SetLinearVelocity(velocity);
			}*/
			
			updateAnimation();
		}
		
		public function walk(direction:b2Vec2 = null):void {
			if (direction == null)
				direction = RIGHT;
			_walkingDirection = direction;
			_walking = true;
			_fixture.SetFriction(0);
		}
		
		public function turnAround():void {
			if (_walking) {
				_walkingDirection.NegativeSelf();
			}
		}
		
		public function stop():void {
			_walking = false;
			_fixture.SetFriction(_friction);
		}
		
		public function jump():void {
			_jumping = true;
		}
		
		/**
		 * Returns the absolute walking speed, taking moving platforms into account.
		 * Isn't super performance-light, so use sparingly.
		 */
		public function getWalkingSpeed():Number {
			var groundVelocityX:Number = 0;
			for each (var groundContact:b2Fixture in _groundContacts) {
				groundVelocityX += groundContact.GetBody().GetLinearVelocity().x;
			}
			
			return _body.GetLinearVelocity().x - groundVelocityX;
		}
		
		/**
		 * Hurts the hero, disables his controls for a little bit, and dispatches the onTakeDamage signal. 
		 */		
		public function hurt():void {
			_hurt = true;
			//controlsEnabled = false;
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
			onTakeDamage.dispatch();
			
			//Makes sure that the hero is not frictionless while his control is disabled
			/*if (_playerMovingHero) {
				_playerMovingHero = false;
				_fixture.SetFriction(_friction);
			}*/
		}
		
		override protected function defineBody():void {
			super.defineBody();
			_bodyDef.fixedRotation = true;
			_bodyDef.allowSleep = false;
		}
		
		override protected function createShape():void {
			_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.1);
		}
		
		override protected function defineFixture():void {
			super.defineFixture();
			_fixtureDef.friction = _friction;
			_fixtureDef.restitution = 0;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("GoodGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAll();
		}
		
		override public function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void {
				
			var other:Box2DPhysicsObject =  Box2DPhysicsObject.CollisionGetOther(this, contact);
			
			var heroTop:Number = y;
			var objectBottom:Number = other.y + (other.height / 2);
			
			if (objectBottom < heroTop)
				contact.SetEnabled(false);
		}
		
		override public function handleBeginContact(contact:b2Contact):void {
			var collider:Box2DPhysicsObject = Box2DPhysicsObject.CollisionGetOther(this, contact);
			
			if (_enemyClass && collider is _enemyClass) {
				if (_body.GetLinearVelocity().y < killVelocity && !_hurt) {
					hurt();
					
					//fling the hero
					var hurtVelocity:b2Vec2 = _body.GetLinearVelocity();
					hurtVelocity.y = -hurtVelocityY;
					hurtVelocity.x = hurtVelocityX;
					if (collider.x > x)
						hurtVelocity.x = -hurtVelocityX;
					_body.SetLinearVelocity(hurtVelocity);
				}
				/*else {
					_springOffEnemy = collider.y - height;
					onGiveDamage.dispatch();
				}*/
			}
			
			
			//Collision angle
			if (contact.GetManifold().m_localPoint) { //The normal property doesn't come through all the time. I think doesn't come through against sensors. {
				var normalPoint:Point = new Point(contact.GetManifold().m_localPoint.x, contact.GetManifold().m_localPoint.y);
				var collisionAngle:Number = new MathVector(normalPoint.x, normalPoint.y).angle * 180 / Math.PI;
				
				if ((collisionAngle > 45 && collisionAngle < 135) || collisionAngle == -90 || collider is Crate)
				{
					_groundContacts.push(collider.body.GetFixtureList());
					_onGround = true;
					updateCombinedGroundAngle();
				}
			}
		}
		
		override public function handleEndContact(contact:b2Contact):void {
			var collider:Box2DPhysicsObject = Box2DPhysicsObject.CollisionGetOther(this, contact);
			
			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(collider.body.GetFixtureList());
			if (index != -1) {
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0)
					_onGround = false;
				updateCombinedGroundAngle();
			}
		}
		
		protected function getSlopeBasedMoveAngle():b2Vec2 {
			return Box2DPhysicsObject.Rotateb2Vec2(new b2Vec2(acceleration, 0), _combinedGroundAngle);
		}
		
		protected function updateCombinedGroundAngle():void {
			_combinedGroundAngle = 0;
			
			if (_groundContacts.length == 0)
				return;
			
			for each (var contact:b2Fixture in _groundContacts)
				var angle:Number = contact.GetBody().GetAngle();
				
			var turn:Number = 45 * Math.PI / 180;
			angle = angle % turn;
			_combinedGroundAngle += angle;
			_combinedGroundAngle /= _groundContacts.length;
		}
		
		protected function endHurtState():void {
			_hurt = false;
			//controlsEnabled = true;
		}
		
		protected function updateAnimation():void {
			var prevAnimation:String = _animation;
			
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			if (_hurt) {
				_animation = "hurt";
			}
			else if (!_onGround) {
				_animation = "jump";
			}
			/*else if (_ducking) {
				_animation = "duck";
			}*/
			else {
				var walkingSpeed:Number = getWalkingSpeed();
				if (walkingSpeed < -acceleration) {
					_inverted = true;
					_animation = "walk";
				}
				else if (walkingSpeed > acceleration) {
					_inverted = false;
					_animation = "walk";
				}
				else {
					_animation = "idle";
				}
			}
			
			if (prevAnimation != _animation) {
				onAnimationChange.dispatch();
			}
		}
	}
}