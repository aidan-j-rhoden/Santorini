extends Node3D

@onready var building = preload("res://buildings/building.tscn")
@onready var player = preload("res://player/player.tscn")
@onready var Camera = preload("res://player/camera_controller.tscn")
@onready var guide = preload("res://buildings/Guide.tscn")
@onready var worker_male = preload("res://worker/worker_male.tscn")

var current_player = 1
var previous_player = 2

var player1_cam
var player1_workers_amount = 0

var player2_cam
var player2_workers_amount = 0

func _ready():
	if Settings.gamemode == 0:
		$Grid.visible = false
		get_node("Players").add_child(player.instantiate())
		for x in range(floor((Settings.width/2.0)) * -1, Settings.width - floor(Settings.width/2.0)):
			for z in range(floor((Settings.length/2.0)) * -1, Settings.length - floor(Settings.length/2.0)):
				if randi() % 3 < 2:
					var level = building.instantiate()
					level.position = Vector3(x * 15, 0, z * 15)
					level.rotation_degrees = Vector3(0, randi() % 4 * 90, 0)
					get_node("Buildings").add_child(level, true)

	if Settings.gamemode == 1:
		build_guides()
		current_player = 1

		player1_cam = Camera.instantiate()
		player2_cam = Camera.instantiate()
		player1_cam.player = 1
		player2_cam.player = 2

		$Cameras.add_child(player1_cam)
		$Cameras.add_child(player2_cam)


func player_took_action():
	if current_player == 1:
		current_player = 2
	else:
		current_player = 1
	change_player()


func I_got_clicked(here):
	if current_player == 1:
		player1_workers_amount += 1
		var wkr = worker_male.instantiate()
		$Players/P1_W.add_child(wkr)
		wkr.global_position = here
	elif current_player == 2:
		player2_workers_amount += 1
		var wkr = worker_male.instantiate()
		$Players/P2_W.add_child(wkr)
		wkr.global_position = here
	if player2_workers_amount == 2 and player1_workers_amount == 2:
		Globals.stage = "fight"
	player_took_action()


func change_player():
	if current_player == 1:
		player1_cam.set_current()
	else:
		player2_cam.set_current()


func build_guides():
	for x in range(floor((Settings.width/2.0)) * -1, Settings.width - floor(Settings.width/2.0)):
			for z in range(floor((Settings.length/2.0)) * -1, Settings.length - floor(Settings.length/2.0)):
				var guide_instance = guide.instantiate()
				guide_instance.position = Vector3(x * 15, 0, z * 15)
				guide_instance.rotation_degrees = Vector3(0, randi() % 4 * 90, 0)
				get_node("Guides").add_child(guide_instance, true)
