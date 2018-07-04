extends Node2D

# The size of each room.
const ROOM_SIZE = Vector2(512, 288)

# room to start
export var start_room = Vector2(0,0)
export var start_position = Vector2(128,208)

# Determines if fullscreen is active
var is_fullscreen = false

# Safe distance for the player to teleport to when transitioning.
const TRANSITION_PADDING = 16

var border_collision_scene = preload("res://collisions/BorderCollision.tscn")
var border_collision = null

onready var player = $"Ghost"

var transition_speed = 15
var areas = Array()
var previous_area = null
var current_area = null

class Area:
	var pos
	var root_node
	var scene
	var scene_instance
	
	func _init(root_node, pos):
		self.root_node = root_node
		self.pos = pos
		
		reload()
	
	func activate():
		if scene_instance:
			scene_instance.get_node("LevelProperties").activate()
	
	func deactivate():
		if scene_instance:
			scene_instance.get_node("LevelProperties").deactivate()
	
	func reload():
		if scene_instance != null:
			unload()
		
		var resource = "res://levels/" + str(pos.x) + "," + str(pos.y) + ".tscn"
		
		if File.new().file_exists(resource):
			self.scene = load(resource)
			self.scene_instance = self.scene.instance()
			self.scene_instance.global_position += pos * ROOM_SIZE
			root_node.add_child(self.scene_instance)
			
	func unload():
		root_node.areas.erase(self)
		if scene_instance != null:
			root_node.remove_child(scene_instance)
		
# sets player position
func _ready():
	
	var start_pos = Vector2(start_room.x * ROOM_SIZE.x + start_position.x, start_room.y * ROOM_SIZE.y + start_position.y)
	
	$"Ghost"._position = start_pos

# general input events for settings
func _input(event):
	
	# Changes state from fullscreen to normal and vice versa
	if event.is_action_pressed("switch_fullscreen"):
		
		is_fullscreen = !is_fullscreen
		
		if is_fullscreen: OS.set_window_fullscreen(true)
		else: OS.set_window_fullscreen(false)
	
	# Reloads the current scene
	# Todo: Save progress
	if event.is_action_pressed("reload"):
		
		# this key should call a reload function, which reloads the current level and sets the position 
		# of the ghost to the position, where he entered the room
		pass
		
func round_area_position(pos):
	pos.x = floor(pos.x / ROOM_SIZE.x)
	pos.y = floor(pos.y / ROOM_SIZE.y)
	return pos

func load_area(pos):
	var area = null
	for i in range(0, areas.size()):
		if areas[i].pos == pos:
			area = areas[i]
		else:
			areas[i].deactivate()
	
	if area == null:
		area = Area.new(self, pos)
		areas.push_back(area)
	
	area.activate()
	return area

func _process(delta):
	var pos = round_area_position(player.global_position)
	
	var camera = $"Camera"
	var target_pos = (pos + Vector2(0.5, 0.5)) * ROOM_SIZE
	camera.global_position += (target_pos - camera.global_position) * min(delta * transition_speed, 1)
	if (target_pos - camera.global_position).length_squared() < 0.1:
		if border_collision != null:
			remove_child(border_collision)
			border_collision = null
		
		if previous_area:
			previous_area.unload()
			previous_area = null
	
	var area = load_area(pos)
	if area != current_area:
		previous_area = current_area
		current_area = area
		
		player.unpossess()
		var gpos = player.global_position
		gpos = Vector2(
			clamp(gpos.x, pos.x * ROOM_SIZE.x + TRANSITION_PADDING, (pos.x + 1) * ROOM_SIZE.x - TRANSITION_PADDING),
			clamp(gpos.y, pos.y * ROOM_SIZE.y + TRANSITION_PADDING, (pos.y + 1) * ROOM_SIZE.y - TRANSITION_PADDING)
		)
		player.global_position = gpos
		player._position = gpos
		
		border_collision = border_collision_scene.instance()
		add_child(border_collision)
		border_collision.global_position = pos * ROOM_SIZE
		
		var label = $"Camera/TransitionText/Label"
		var text = current_area.scene_instance.get_node("LevelProperties").title_text
		if label.text != text:
			label.text = text
			$"Camera/TransitionText/AnimationPlayer".play("AreaEntered")
		
		var music = current_area.scene_instance.get_node("LevelProperties").music
		if music != $"MusicPlayer".stream:
			$"MusicPlayer".stream = music
			if music == null:
				# TODO: (Joex3) Fade out.
				$"MusicPlayer".stop()
			else:
				$"MusicPlayer".play()