extends Node2D

const ColorChannel = preload("res://scripts/ColorChannel.gd")

export(ColorChannel.Enum) var color_channel = ColorChannel.RED
export(bool) var active

func _enter_tree():
	add_user_signal("activate")
	add_user_signal("deactivate")

func activate():
	if !active:
		active = true
		for node in get_tree().get_nodes_in_group("Receiver"):
			node.activate(color_channel)
		emit_signal("activate")

func deactivate():
	if active:
		active = false
		for node in get_tree().get_nodes_in_group("Receiver"):
			node.deactivate(color_channel)
		emit_signal("deactivate")

func toggle():
	if active:
		activate()
	else:
		deactivate()