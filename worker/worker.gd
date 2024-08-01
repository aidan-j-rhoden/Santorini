extends Node3D

@onready var p1mat = preload("res://materials/player1worker.tres")
@onready var p2mat = preload("res://materials/player2worker.tres")

@export var player:int
var mouse_inside:bool = false
var waiting_orders: bool = false
var level = 0

func _ready() -> void:
	$Area3D/MeshInstance3D.visible = false
	if player == 1:
		$MeshInstance3D.set_surface_override_material(0, p1mat)
		$MeshInstance3D/MeshInstance3D2.set_surface_override_material(0, p1mat)
		$MeshInstance3D/MeshInstance3D2/MeshInstance3D.set_surface_override_material(0, p1mat)
	elif player == 2:
		$MeshInstance3D.set_surface_override_material(0, p2mat)
		$MeshInstance3D/MeshInstance3D2.set_surface_override_material(0, p2mat)
		$MeshInstance3D/MeshInstance3D2/MeshInstance3D.set_surface_override_material(0, p2mat)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left-mouse") and mouse_inside:
		waiting_orders = true
		$Control/MoveHint.show()
		Globals.current_worker[0] = global_position
		Globals.current_worker[1] = level
	if waiting_orders and Input.is_action_just_pressed("escape"):
		waiting_orders =  false
		$Control/MoveHint.hide()
		Globals.current_worker[0] = Vector3.INF
		Globals.current_worker[1] = 0
	if Globals.moved_and_built[0] and Globals.current_player == player:
		$Control/BuildHint.show()
	else:
		$Control/BuildHint.hide()


func _physics_process(_delta: float) -> void:
	if Globals.stage == "fight":
		if mouse_inside and not Input.is_action_pressed("middle-mouse") and not waiting_orders:
			$Area3D/MeshInstance3D.visible = true
		elif not waiting_orders:
			$Area3D/MeshInstance3D.visible = false
		if waiting_orders:
			if not $Area3D/AnimationPlayer.is_playing():
				$Area3D/AnimationPlayer.play("ready")
			if Globals.move_here[0] != Vector3.INF:
				global_position = Globals.move_here[0]
				level = Globals.move_here[1]

				Globals.move_here = [Vector3.INF, 0]
				Globals.current_worker[0] = global_position
				Globals.current_worker[1] = 0
				Globals.moved_and_built[0] = true

				waiting_orders = false
				$Control/MoveHint.visible = false
				if player == 1:
					Globals.p1_worker_positions[name] = global_position
				elif player == 2:
					Globals.p2_worker_positions[name] = global_position
				Globals.moved_and_built[0] = true
	elif Globals.stage == "win":
		$Area3D/MeshInstance3D.visible = false


func _process(_delta: float) -> void:
	if level >= 3:
		win()
		level = 0


func win():
	Globals.stage = "win"
	print("Player " + str(player) + " won!")
	$Control/Win/AnimationPlayer.play("win")
	$Control/BuildHint.hide()


func _on_mouse_entered() -> void:
	if Globals.stage == "fight" and Globals.current_player == player and not Globals.moved_and_built[0]:
		if Globals.current_worker[0] != Vector3.INF:
			return
		mouse_inside = true


func _on_mouse_exited() -> void:
	mouse_inside = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ready":
		$Area3D/AnimationPlayer.play("waiting")
