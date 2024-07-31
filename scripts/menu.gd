extends Control

var main = preload("res://levels/main.tscn")
@onready var gamemode = $home/VBoxContainer/GamemodeMargin/gamemode
@onready var player = preload("res://player/player.tscn")

var faded = false

func _ready() -> void:
	Globals.stage = "setup"


func _process(_delta: float) -> void:
	if Globals.stage == "fight" and not faded:
		faded = true
		$game/VBoxContainer/MarginContainer/Label.text = "Fight!"
		await get_tree().create_timer(5).timeout
		$game/AnimationPlayer.play("Fadeout")


func _on_start_pressed():
	$home.hide()
	await get_tree().create_timer(0.5).timeout
	Settings.gamemode = gamemode.selected
	if gamemode.selected == 2:
		get_tree().quit()

	var level = main.instantiate()
	add_child(level)
	$game.show()


func _on_settings_pressed():
	$settings.visible = true
	$home.visible = false


func _on_exit_pressed():
	$settings.visible = false
	$home.visible = true


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
