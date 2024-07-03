extends Node3D
@onready var Building = preload("res://buildings/building.tscn")

@export var level:int = 0
var mouse_inside:bool = false

func _ready() -> void:
	$Guide/MeshInstance3D.visible = false


func _physics_process(_delta: float) -> void:
	if mouse_inside and not Input.is_action_pressed("middle-mouse"):
		$Guide/MeshInstance3D.visible = true
	else:
		$Guide/MeshInstance3D.visible = false
	if $Guide/MeshInstance3D.visible:
		if Input.is_action_just_pressed("left-mouse"):
			if Globals.stage == "setup":
				get_parent().get_parent().I_got_clicked(global_position)
			else:
				if Globals.current_worker != Vector3.ZERO:
					if level == 0:
						Globals.move_here = global_position
					elif level == 1:
						Globals.move_here = global_position + Vector3(0, 4.3, 0)
					elif level == 2:
						Globals.move_here = global_position + Vector3(0, 3.4, 0)
				else:
					move_up()
					get_parent().get_parent().player_took_action()


func move_up():
	if level == 0:
		create_building()
		$Guide.position += Vector3(0.0249, 6.0, -0.1762)
		$Guide.scale = Vector3(0.57, 1, 0.55)
	elif level == 1:
		get_node("building").get_node("Lvl1").get_node("Lvl2").visible = true
		get_node("building").get_node("Lvl1").get_node("Lvl2").get_node("Lvl3").visible = false
		$Guide.position += Vector3(0.1, 4.3, -0.0)
		$Guide.scale = Vector3(0.47, 1, 0.47)
	elif level == 2:
		get_node("building").get_node("Lvl1").get_node("Lvl2").get_node("Lvl3").visible = true
		get_node("building").get_node("Lvl1").get_node("Lvl2").get_node("Lvl3").get_node("Lvl4").visible = false
		$Guide.position += Vector3(0.0, 3.4, 0.2)
		$Guide.scale = Vector3(0.3, 0.8, 0.3)
	elif level == 3:
		get_node("building").get_node("Lvl1").get_node("Lvl2").get_node("Lvl3").get_node("Lvl4").visible = true
	level += 1
	if level > 3:
		$Guide.visible = false


func create_building():
	var building = Building.instantiate()
	add_child(building, true)
	building.global_position = self.global_position
	building.rotation_degrees.y = randi_range(0, 3) * 90


func _on_mouse_entered() -> void:
	var worker_dict:Dictionary
	var occupied_spaces:Array

	for wkr in Globals.p1_worker_positions:
		occupied_spaces.append(Globals.p1_worker_positions[wkr])
	for wkr in Globals.p2_worker_positions:
		occupied_spaces.append(Globals.p2_worker_positions[wkr])

	if Globals.current_player == 1:
		worker_dict = Globals.p1_worker_positions
	else:
		worker_dict = Globals.p2_worker_positions

	if global_position in occupied_spaces: # The space is occupied
		return

	if Globals.current_worker != Vector3.ZERO:
		if _close_enough(Globals.current_worker):
			mouse_inside = true
		return

	for worker in worker_dict.keys():
		if worker_dict[worker] == null:
			continue
		if Globals.stage == "fight":
			if _close_enough(worker_dict[worker]):
				mouse_inside = true
				return

	if Globals.stage == "setup":
		mouse_inside = true


func _on_mouse_exited() -> void: # This one's much simplier, eh?
	mouse_inside = false


func _close_enough(target) -> bool:
	var distance = global_position.distance_to(target)
	if distance/15.0 < 1.5:
		if 0 < distance/15.0:
			return true
	return false
