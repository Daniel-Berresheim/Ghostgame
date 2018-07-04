extends Node2D

const ColorChannel = preload("res://scripts/ColorChannel.gd")

export(ColorChannel.Enum) var color_channel = ColorChannel.RED
export(bool) var inverted = false
var activation_strength = 0

func _enter_tree():
	add_user_signal("activate")
	add_user_signal("deactivate")

func _ready():
	if inverted:
		emit_signal("activate")

func activate(channel):
	if channel == color_channel:
		activation_strength += 1
		
		if activation_strength == 1:
			if !inverted: emit_signal("activate")
			else:         emit_signal("deactivate")

func deactivate(channel):
	if channel == color_channel:
		activation_strength -= 1
		
		if activation_strength == 0:
			if !inverted: emit_signal("deactivate")
			else:         emit_signal("activate")