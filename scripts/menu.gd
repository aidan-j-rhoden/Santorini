extends Control

var main = preload("res://levels/main.tscn")
@onready var gamemode = $home/gamemode
@onready var player = preload("res://player/player.tscn")

func _ready() -> void:
	Globals.stage = "setup"


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


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
