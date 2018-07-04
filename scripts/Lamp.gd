extends Node2D

export(bool) var turned_on = false setget set_turned_on
var possessed = false setget ,get_possessed

onready var _snd_turn_on = $"Sounds/TurnOn"
onready var _snd_turn_off = $"Sounds/TurnOff"

func _ready():
	$"Possessable".connect("possessed", self, "_possessed")
	$"Possessable".connect("unpossessed", self, "_unpossessed")

func _input(event):
	if possessed and event is InputEvent and event.is_action_pressed("action"):
		set_turned_on(!turned_on)

func _possessed(player):
	possessed = true
	_update_sprite()

func _unpossessed(player):
	possessed = false
	_update_sprite()

func get_possessed():
	return possessed

func set_turned_on(value):
	
	turned_on = value
	
	if _snd_turn_on != null:
		if value:
			_snd_turn_on.play();
			$"Light".enabled = true
			$"AnimationPlayer".play("On")
		else:
			_snd_turn_off.play();
			$"Light".enabled = false
			$"AnimationPlayer".play("Off")
	
	_update_sprite()

func _update_sprite():
	
	if is_inside_tree():
		var sprite = get_node("Sprite")
		if sprite != null:
			sprite.frame = int(possessed) * 2 + int(turned_on)