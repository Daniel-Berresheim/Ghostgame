tool
extends Node2D

var is_ready = false
var is_active = true
export var title_text = ""
export var base_color = Color(1.0, 1.0, 1.0) setget set_base_color
export(AudioStream) var music;

func _ready():
	is_ready = true
	set_base_color(base_color)

func activate():
	if !is_active:
		if is_ready:
			$"CanvasModulate".visible = true

func deactivate():
	if is_active:
		is_active = false
		if is_ready:
			$"CanvasModulate".visible = false

func set_base_color(value):
	if is_ready:
		$"CanvasModulate".color = value
	
	base_color = value
