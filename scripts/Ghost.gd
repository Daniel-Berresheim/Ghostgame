extends KinematicBody2D

# Deadzone of controller axis.
const DEADZONE = 0.25

# Deadzone for the movement in pixels per second.
# Movements with a length smaller than this value will be ignored.
const MOVEMENT_DEADZONE = 30

enum State {
	STATE_IDLE,
	STATE_POSSESSING
}

# Movement speed in pixels per second.
export(float) var movement_speed = 1200

# Friction of the movement.
# The player's speed will be multiplied by this value in the span of one second.
export(float) var friction = 0.0001

# The state of the player.
var state = STATE_IDLE setget set_state

# Set to the possessed object.
var possessed_object = null

# possessible index
var _possessible_index = 0

# Private position used to calculate movement.
# The actual position property will be set to a rounded version of this variable.
onready var _position = position

# Private speed used to calculate movement.
var _speed = Vector2(0, 0)

# Array of possessables that are currently in range to be possessed.
var _possessables_in_range = Array()

onready var _snd_move = $"Sounds/Move"

var can_switch = true

# Sets the state of the player.
func set_state(value):
	if value == STATE_POSSESSING:
		$"Sprite".visible = false
		_snd_move.playing = false
		# Divide by length instead of setting to Vector2(0, 0).
		# This keeps the sign of speed (e.g. for sprite orientation).
		_speed /= _speed.length()
	elif value == STATE_IDLE:
		$"Sprite".visible = true
	
	state = value

func unpossess():
	# Switches the player to an unpossessed state.
	if possessed_object != null and state == STATE_POSSESSING: possessed_object.unpossess()

func _ready():
	$"AnimationPlayer".play("Idle")

func _input(event):
	
	# Changes the possessable object
	if event.is_action_pressed("switch_possessale"):
		
		# change the selected object
		if state == STATE_IDLE:
		
			can_switch = true
			if state != STATE_POSSESSING: _possessible_index += 1
		
		# change between objects while possessing
		elif state == STATE_POSSESSING:
			
			var areas = get_tree().get_nodes_in_group("Possessables")
			var ghost = get_node("GhostArea")
		
			var i = 0
			while i < areas.size():
				if areas[i].possessed == true or !areas[i].overlaps_area(ghost):
					areas.remove(i)
				else: i+=1
		
			if areas.size() > 0:
				unpossess()
			
				_possessible_index += 0.5
				can_switch = false
				areas[int(_possessible_index) % areas.size()].possess(self)
		
	# Enables the Ghost to possess other objects
	if event.is_action_pressed("possess"):
		if _possessables_in_range.size() != 0 and state == STATE_IDLE:
			_possessables_in_range[int(_possessible_index) % _possessables_in_range.size()].possess(self);
		elif possessed_object != null and state == STATE_POSSESSING:
			possessed_object.unpossess()
	
func _physics_process(delta):
	
	if state == STATE_IDLE:
		
		var analog = _deadzone(Vector2(Input.get_joy_axis(0, JOY_AXIS_0), Input.get_joy_axis(0, JOY_AXIS_1)))
		if analog != Vector2(0, 0):
			_speed += analog * movement_speed * delta
		else:
			var dir = Vector2(0, 0)
			dir.x += int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
			dir.y += int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
			_speed += dir.normalized() * movement_speed * delta
			
		$"Sprite".flip_h = _speed.x < 0
			
		if _speed.length() > 10:
			_snd_move.volume_db = clamp(-48 + _speed.length() * 0.2, -48, 0)
			
			if not _snd_move.playing:
				_snd_move.playing = true
		else:
			_snd_move.playing = false
			
		_position += move_and_slide(limit_movement(_speed)) * delta
		_speed *= pow(friction, delta)
			
		position = Vector2(round(_position.x), round(_position.y))
			
		# possess message above selected object, which can be possessed
		if _possessables_in_range.size() > 0:
			for i in _possessible_index:
				_possessables_in_range[(i) % _possessables_in_range.size()].get_node("MSG_Possess").hide()
			_possessables_in_range[int(_possessible_index) % _possessables_in_range.size()].get_node("MSG_Possess").show()
	

func limit_movement(axis):
	if abs(axis.x) < MOVEMENT_DEADZONE:
		axis.x = 0
	if abs(axis.y) < MOVEMENT_DEADZONE:
		axis.y = 0
	
	return axis

func _deadzone(axis):
	var length = axis.length()
	
	if length < DEADZONE:
		return Vector2(0, 0)
	if length > 1:
		return axis.normalized()
	
	return axis