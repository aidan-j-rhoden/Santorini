extends Node3D

@onready var building = preload("res://buildings/building.tscn")
@onready var player = preload("res://player/player.tscn")
@onready var Camera = preload("res://player/camera_controller.tscn")
@onready var guide = preload("res://buildings/Guide.tscn")
@onready var grass = preload("res://Props/Vegetation/grassystuff.tscn")
@onready var worker_male = preload("res://worker/worker_male.tscn")

var player1_cam
var player1_workers_amount = 0

var player2_cam
var player2_workers_amount = 0

var faded = false

func _ready():
	if Settings.gamemode == 0:
		$Control.hide()
		$Grid.hide()
		$Cameras/TopDown.queue_free()
		get_node("Players").add_child(player.instantiate())
		for x in range(floor((Settings.width/2.0)) * -1, Settings.width - floor(Settings.width/2.0)):
			for z in range(floor((Settings.length/2.0)) * -1, Settings.length - floor(Settings.length/2.0)):
				if randi() % 3 < 2:
					var level = building.instantiate()
					get_node("Buildings").add_child(level, true)
					level.global_position = Vector3(x * 15, 0.0, z * 15)
					level.rotation_degrees = Vector3(0, randi() % 4 * 90, 0)

		build("grass")

	if Settings.gamemode == 1:
		build("guides")
		Globals.current_player = 1

		player1_cam = Camera.instantiate()
		player2_cam = Camera.instantiate()
		player1_cam.player = 1
		player2_cam.player = 2

		$Cameras.add_child(player1_cam)
		$Cameras.add_child(player2_cam)


func _physics_process(_delta: float) -> void:
	if Globals.p1_workers_stuck[0] and Globals.p1_workers_stuck[1]:
		get_node("Players/P2_W").get_children()[0].win()
	if Globals.p2_workers_stuck[0] and Globals.p2_workers_stuck[1]: # If both of player two's workers are stuck
		get_node("Players/P1_W").get_children()[0].win() # player one wins.


func _process(_delta: float) -> void:
	if Globals.stage == "fight" and not faded:
		faded = true
		$game/VBoxContainer/MarginContainer/Label.text = "Fight!"
		await get_tree().create_timer(5).timeout
		$game/AnimationPlayer.play("Fadeout")


func check_for_buildable():
	Globals.buildable_spaces = 0
	for child in $Guides.get_children():
		if child.avalibility_checks:
			Globals.buildable_spaces += 1
	if Globals.buildable_spaces < 1:
		return false
	return true


func check_for_moveable(pos, level):
	for child in $Guides.get_children():
		if child.avalibility_checks(pos, level):
			return true
	return false


func player_took_action():
	Globals.moved_and_built = [false, false]
	for child in $Players.get_children():
		for worker in child.get_children():
			worker.check_for_win()

	if Globals.current_player == 1:
		Globals.current_player = 2
	else:
		Globals.current_player = 1
	change_player()


func I_got_clicked(here):
	if Globals.current_player == 1:
		var wkr = worker_male.instantiate()
		wkr.name = "p1wkr" + str(player1_workers_amount)
		wkr.player = 1
		wkr.id = player1_workers_amount
		$Players/P1_W.add_child(wkr)
		wkr.global_position = here
		Globals.p1_worker_positions[wkr.name] = here
		player1_workers_amount += 1
	elif Globals.current_player == 2:
		var wkr = worker_male.instantiate()
		wkr.name = "p2wkr" + str(player2_workers_amount)
		wkr.player = 2
		wkr.id = player2_workers_amount
		$Players/P2_W.add_child(wkr)
		wkr.global_position = here
		Globals.p2_worker_positions[wkr.name] = here
		player2_workers_amount += 1
	if player2_workers_amount == 2 and player1_workers_amount == 2:
		Globals.stage = "fight"
	player_took_action()


func change_player():
	if Globals.stage == "win":
		$Control/MarginContainer/Label.hide()
		return

	$Control/MarginContainer/Label.text = "Player " + str(Globals.current_player)
	if Globals.stage == "setup":
		return
	if Globals.current_player == 1:
		player1_cam.set_current()
	else:
		player2_cam.set_current()


func build(item):
	for x in range(floor((Settings.width/2.0)) * -1, Settings.width - floor(Settings.width/2.0)):
			for z in range(floor((Settings.length/2.0)) * -1, Settings.length - floor(Settings.length/2.0)):
				if item == "guides":
					var guide_instance = guide.instantiate()
					get_node("Guides").add_child(guide_instance, true)
					guide_instance.global_position = Vector3(x * 15, 0.0, z * 15)
					Globals.guide_positions[guide_instance.name] = guide_instance.global_position
				elif item == "grass":
					var occupied = false
					for child in $Buildings.get_children():
						if child.global_position == Vector3(x * 15, 0.0, z * 15):
							occupied = true
							break
					if occupied:
						continue
					var grass_instance = grass.instantiate()
					get_node("Props/Vegitation").add_child(grass_instance, true)
					grass_instance.global_position = Vector3(x * 15, 0.01, z * 15)
					Globals.guide_positions[grass_instance.name] = grass_instance.global_position
