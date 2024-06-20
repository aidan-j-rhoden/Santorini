extends Control

var main = preload("res://levels/main.tscn")
@onready var gamemode = $home/gamemode
@onready var player = preload("res://player/player.tscn")

func _on_start_pressed():
	Settings.gamemode = gamemode.selected
	if gamemode.selected == 2:
		get_tree().quit()

	var level = main.instantiate()
	add_child(level)
	self.hide()


func _on_settings_pressed():
	$settings.visible = not $settings.visible


func _on_exit_pressed():
	$settings.visible = false
