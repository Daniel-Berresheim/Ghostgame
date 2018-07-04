extends KinematicBody2D

# todo:
# - dying: the player falls over with an animation and sound; the screen fades out and the level resets
# - some humans have other abilities, which are shown on the sprite; e.g. cannot be possessed

# todo (later):
# - will be scared of some actions of the player and from movables
# - can run away in fear
# - maybe they have a value of how likely they are to be afraid
# - this value can be raised if it's dark, etc. and through events
# - adults could have a higher resistance to scary things

# Deadzone of controller axis.
const DEADZONE = 0.25

var alive = true

# gravity applied on the character
export var gravity = Vector2(0, 1400)

# The speed of the human will be multiplied by this value in the span of one second.
export(float) var friction = 0.000025
export(float) var air_friction = 0.000010

# Movement speed in pixels per second.
export(float) var movement_speed = 1200

# Jump strength
export(float) var jump_strength = 12000

# The current speed of the human.
var speed = Vector2(0.0, 0.0)

# Movement that actually occured since the last _physics_process.
var actual_movement = Vector2()

# True if colliding with ground.
var on_ground = true

var fall_position = 0

# The collision box of the human.
var collision_box = Rect2()

var was_walking = false

onready var _p = $"Possessable"
onready var _animation = get_node("AnimationPlayer")

func _ready():
	
	_animation.play("Idle")
	
	# get the size of the object
	collision_box = Rect2($CollisionShape2D.position, $CollisionShape2D.get_shape().extents * 2 * $CollisionShape2D.scale)

func _physics_process(delta):
	
	# tests, whether the player is on ground
	var on_ground_new = test_move(global_transform, Vector2(0, 1))
	
	var walking = false
	
	# tests for movables on top of the human
	var collision_up = $"CollisionUp".get_overlapping_bodies()
	collision_up.erase(self)
	
	for i in collision_up.size():
		
		# humans die if movables fall on them
		if collision_up[i].is_in_group("Movables") and !collision_up[i].speed.y < 0: die()
	
	if on_ground_new:
		
		if !on_ground:
			# human dies, if fallheight is over 2.5 blocks (40 pixel)
			var fall_height = -(fall_position - global_position.y)
			
			if fall_height > 40: die()
		
		# jump
		if _p.possessed and alive:
			if Input.is_action_just_pressed("jump"):
				
				speed.y = -jump_strength * delta
		
	# if on ground and possessed, calculate input direction and speed
	if _p.possessed and alive:
		var analog = _deadzone(Vector2(Input.get_joy_axis(0, JOY_AXIS_0), 0))
		if analog != Vector2():
			speed += analog * movement_speed * delta
			if on_ground_new: 
				walking = true
		else:
			if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
				var dir = Vector2()
				dir.x += int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
				speed += dir.normalized() * movement_speed * delta
				if on_ground_new: 
					walking = true
			
	# animation
	if walking and !was_walking: _animation.play("Walking")
	elif !walking and was_walking: _animation.play("Idle")
		
	was_walking = walking
		
	# looking direction
	if speed.x < 0: $"Sprite".flip_h = false
	elif speed.x > 0: $"Sprite".flip_h = true
		
	if on_ground:
		
		if !on_ground_new:
			
			# start falling
			# mark position as start point for falling
			fall_position = global_position.y
		
	else:
		
		speed += gravity * delta
		
	if on_ground_new: speed.x *= pow(friction, delta)	
	else: speed.x *= pow(air_friction, delta)
	
	on_ground = on_ground_new
	
	actual_movement = global_position
	speed = move_and_slide(speed, Vector2(0, -1))
	actual_movement = (actual_movement - global_position) / delta
	
	# moves the player along with the human
	if _p.possessed: _p.player.global_position = global_position

func die():
	
	if alive:
		# if a human dies, he plays an animation and loses his collision with Movables and other humans
		# todo: 
		# - play an dying animation
		# - the human is now unpossessable and shows no possess message
		# - the screen fades out and the level resets
		$"AnimationPlayer".play("Die")
		alive = false
		set_collision_layer_bit(3, false)
		set_collision_mask_bit(3, false)
		$"Possessable".unpossess()
	
func _deadzone(axis):
	
	var length = axis.length()
	
	if length < DEADZONE:
		return Vector2()
	if length > 1:
		return axis.normalized()
	
	return axis