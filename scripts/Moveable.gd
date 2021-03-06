extends KinematicBody2D

# Deadzone of controller axis.
const DEADZONE = 0.25

export var gravity = Vector2(0, 1600)

# Movement speed in pixels per second.
export(float) var movement_speed = 1100

# Friction of the movement.
# The player's speed will be multiplied by this value in the span of one second.
export(float) var friction = 0.00002

# The current speed of the moveable.
var speed = Vector2()

# Movement that actually occured since the last _physics_process.
var actual_movement = Vector2()

# True if colliding with ground.
var on_ground = true

onready var _p = $"Possessable"

# The collision box of the human.
var collision_box = Rect2()

# Snapes the position.
func snap_falling_position():
	var gpos = global_position
	gpos.x += sign(speed.x) * 0.01
	global_position = gpos
	speed.x = 0

func _ready():
	add_user_signal("impact", ["amount"])
	
	# get the size of the object
	var points = $CollisionShape2D.get_shape().get_points()
			
	var min_pos = Vector2(points[0].x, points[0].y)
	var max_pos = Vector2(points[0].x, points[0].y)
			
	for i in points.size():
				
		if points[i].x < min_pos.x: min_pos.x = points[i].x
		if points[i].y < min_pos.y: min_pos.y = points[i].y
				
		if points[i].x > max_pos.x: max_pos.x = points[i].x
		if points[i].y > max_pos.y: max_pos.y = points[i].y
	
	collision_box = Rect2($CollisionShape2D.position, Vector2(max_pos.x - min_pos.x, max_pos.y - min_pos.y) * $CollisionShape2D.scale)

func move_objects_on_top(floor_speed):
	var objects = get_tree().get_nodes_in_group("Movables")
	
	var humans = get_tree().get_nodes_in_group("Humans")
	for i in humans.size():
		objects.push_back(humans[i])
	
	var delta = get_physics_process_delta_time()
	
	var t_position = global_position + collision_box.position
	var t_size = collision_box.size
	
	var tlu = Vector2(t_position.x - t_size.x/2 + 1, t_position.y - t_size.y/2 -1)
	var trd = Vector2(t_position.x + t_size.x/2 - 1, t_position.y - t_size.y/2)
	
	for i in objects.size():
		if objects[i] == self:
			continue
		
		var overlap = true
		
		var e_position = objects[i].global_position + objects[i].collision_box.position
		var e_size = objects[i].collision_box.size
		
		var elu = Vector2(e_position.x - e_size.x/2, e_position.y - e_size.y/2)
		var erd = Vector2(e_position.x + e_size.x/2, e_position.y + e_size.y/2)
		
		# check for collision
		if tlu.x > erd.x or elu.x > trd.x: overlap = false
		if tlu.y > erd.y or elu.y > trd.y: overlap = false
		
		if overlap:
			if objects[i].is_in_group("Movables"):
				var actual_movement = objects[i].global_position
				objects[i].move_and_slide(floor_speed, Vector2(0, -1))
				objects[i].move_objects_on_top((objects[i].global_position - actual_movement) / delta)
			else:
				objects[i].move_and_slide(floor_speed, Vector2(0, -1))

func _physics_process(delta):
	
	var on_ground_new = test_move(global_transform, Vector2(0, 1))
	
	if on_ground_new:
		
		# todo: 
		# - moving other Movables by pushing them
		# - moving this code block to another position to save performance
		
		move_objects_on_top(speed)
		
		# if the object was falling and hits the ground, it stops playing a falling sound and an impact sound occures
		if not on_ground:
			
			var snd_falling = $"Sounds/Falling"
			snd_falling.stop()
			
			emit_signal("impact", speed.x)
			var snd_impact = $"Sounds/Impact"
			snd_impact.volume_db = clamp(-60 + actual_movement.length() * 8, -60, -2)
			snd_impact.play()
		
		# if the object is possessable, the horizontal moving direction will be determined
		if _p.possessed:
			var analog = _deadzone(Vector2(Input.get_joy_axis(0, JOY_AXIS_0), 0))
			if analog != Vector2():
				speed += analog * movement_speed * delta
			else:
				var dir = Vector2()
				dir.x += int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
				speed += dir.normalized() * movement_speed * delta
	else:
		
		if _p.possessed and on_ground: snap_falling_position()
		
		var snd_falling = $"Sounds/Falling"
		if not snd_falling.is_playing():
			snd_falling.play()
		
		snd_falling.volume_db = clamp(-60 + actual_movement.length(), -60, -24)
		speed += gravity * delta
	
	on_ground = on_ground_new
	
	speed.x *= pow(friction, delta)
	
	actual_movement = global_position
	speed = move_and_slide(speed, Vector2(0, -1))
	actual_movement = (actual_movement - global_position) / delta
	
	# moves the player along with the object it possesses
	if _p.possessed: _p.player.global_position = global_position

func _deadzone(axis):
	var length = axis.length()
	
	if length < DEADZONE:
		return Vector2()
	if length > 1:
		return axis.normalized()
	
	return axis