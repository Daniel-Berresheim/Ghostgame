extends Node2D

onready var anim = $"Possess/AnimationPlayer"

func ready():
	hide();
	
func show():
	if !visible:
		visible = true
		if anim != null:
			anim.play("Idle")

func hide():
	if visible:
		visible = false
		if anim != null:
			anim.stop()