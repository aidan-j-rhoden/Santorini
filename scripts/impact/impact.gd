extends Node3D

class_name Wound

func _ready():
	if Settings.graphics_level <= 1:
		$timer.start()


func _on_timer_timeout():
	queue_free()
