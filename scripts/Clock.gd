extends Node2D

var possessed = false setget ,get_possessed

var state = 0.0
var time = 0.0
const cycle_time = 1.0
const states_pendulum = 8
var sound_tick = 0

func _ready():
	$"Possessable".connect("possessed", self, "_possessed")
	$"Possessable".connect("unpossessed", self, "_unpossessed")
	
	get_node("AnimationPlayer").play("Unpossessed")
	
	# get the current time
	var c_time = OS.get_time()
	time = c_time.hour * 60 * 60 + c_time.minute * 60 + c_time.second

func _process(delta):
	
	# defines the state of the pendulum
	state += (delta / cycle_time)
	if state > cycle_time:
		sound_tick = 0
		$"Sounds/Tick".play()
		state = 0.0
	
	if state > 0.5 and sound_tick == 0:
		sound_tick = 1
		$"Sounds/Tock".play()
	
	# if Q pressed, add time to the clock
	time += delta
	
	if possessed and Input.is_action_pressed("action"):
		time += delta * 3600
	
	_update_sprite()

func _possessed(player):
	possessed = true
	get_node("AnimationPlayer").play("Possessed")

func _unpossessed(player):
	possessed = false
	get_node("AnimationPlayer").play("Unpossessed")

func get_possessed():
	return possessed

func _update_sprite():
	
	if is_inside_tree():
		
		# calculate position of hands
		var big_hand = get_node("BigHand")
		big_hand.frame = (float(int(time) % 3600) / 60 / 60) * 12
		
		var small_hand = get_node("SmallHand")
		small_hand.frame = int(time / (60 * 60)) % 12
		