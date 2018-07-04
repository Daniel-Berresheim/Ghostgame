tool
extends Area2D

var _msg_possess_offset = Vector2(0, 0)
export(Vector2) var msg_posses_offset = Vector2(0, 0) setget set_msg_possess_offset, get_msg_possess_offset

# True, if possessed by the player.
var possessed = false

# Set to the player that is possessing this object.
var player = null

var _editor_hint_msg_possess_time = 0.0
var _is_ready = false

# Possess this object by the given player node.
func possess(player):
	
	if  !Engine.editor_hint:
		
		if self.player != null and self.player.possessed_object != null:
				self.player.possessed_object.unpossess()
		
		self.player = player
		player.state = player.STATE_POSSESSING
		player.possessed_object = self
		possessed = true
		_center_player_pos(player)
		$"Sounds/Possess".play()
		emit_signal("possessed", player)
	
	$"MSG_Possess".hide()

# Unpossesses this object.
func unpossess():
	
	if  !Engine.editor_hint:
	
		# Object must be possessed
		if possessed and player != null:
			player.possessed_object = null
			possessed = false
			_center_player_pos(player)
			$"Sounds/Possess".stop()
			$"Sounds/Unpossess".play()
			emit_signal("unpossessed", player)
			
			player.state = player.STATE_IDLE
			
			# reset player possess list
			player._possessables_in_range = player.get_node("GhostArea").get_overlapping_areas()
			
			# Filter non-possessables
			var j = 0
			for i in range(0, player._possessables_in_range.size()):
				if player._possessables_in_range[i + j].name != "Possessable":
					player._possessables_in_range.remove(i + j)
					j -= 1
	
	$"MSG_Possess".hide()

func _exit_tree():
	unpossess()

func set_msg_possess_offset(value):
	_msg_possess_offset = value
	
	if is_inside_tree():
		if Engine.editor_hint:
			$"MSG_Possess".show()
			_editor_hint_msg_possess_time = 1
			set_process(true)
		
		$"MSG_Possess".position = value

func get_msg_possess_offset():
	return _msg_possess_offset

func _ready():
	add_user_signal("possessed", ["player"])
	add_user_signal("unpossessed", ["player"])
	
	connect("area_entered", self, "_area_entered")
	connect("area_exited", self, "_area_exited")
	
	$"MSG_Possess".hide()
	set_process(false)
	
	# Apply msg_possess_offset (since its setter will be executed before the node is ready).
	set_msg_possess_offset(_msg_possess_offset)

func _center_player_pos(player):
	player.global_position = global_position
	# Update the private position as well.
	# TODO (Joex3): Maybe refactor into function in res://resources/entities/Ghost.tscn?
	player._position = player.position

func _area_entered(area):
	if area.name == "GhostArea" and !Engine.editor_hint:
		# Player node is the parent of the area.
		var player = area.get_parent()
		player._possessables_in_range.push_back(self)
		
		if not player.state == player.STATE_POSSESSING:
			if player._possessables_in_range.size() == 1 and not player.state == player.STATE_POSSESSING:
				$"Sounds/Possessable".play()
				
	$"MSG_Possess".hide();
	
func _area_exited(area):
	if area.name == "GhostArea" and !Engine.editor_hint:
		# Player node is the parent of the area.
		var player = area.get_parent()
		player._possessables_in_range.erase(self)
		
		if not player.state == player.STATE_POSSESSING:
			
			if player._possessables_in_range.size() == 0:
				player = null
	$"MSG_Possess".hide()

func _process(delta):
	if Engine.editor_hint:
		_editor_hint_msg_possess_time -= delta
		if _editor_hint_msg_possess_time <= 0:
			$"MSG_Possess".hide()
			set_process(false)
	