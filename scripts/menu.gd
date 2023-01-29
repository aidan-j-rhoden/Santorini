extends Control

var main = preload("res://main.tscn")

func _on_start_pressed():
	var level = main.instance()
	add_child(level)
	self.hide()


func _on_settings_pressed():
	$settings.visible = not $settings.visible


func _on_exit_pressed():
	$settings.visible = false
