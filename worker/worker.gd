extends Node3D

@onready var p1mat = preload("res://materials/player1worker.tres")
@onready var p2mat = preload("res://materials/player2worker.tres")

@export var player:int
var mouse_inside:bool = false
var waiting_orders: bool = false

func _ready() -> void:
	$Area3D/MeshInstance3D.visible = false
	if player == 1:
		$MeshInstance3D.set_surface_override_material(0, p1mat)
		$MeshInstance3D/MeshInstance3D2.set_surface_override_material(0, p1mat)
		$MeshInstance3D/MeshInstance3D2/MeshInstance3D.set_surface_override_material(0, p1mat)
	else:
		$MeshInstance3D.set_surface_override_material(0, p2mat)
		$MeshInstance3D/MeshInstance3D2.set_surface_override_material(0, p2mat)
		$MeshInstance3D/MeshInstance3D2/MeshInstance3D.set_surface_override_material(0, p2mat)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left-mouse") and mouse_inside:
		waiting_orders = true
		$Control.visible = true
	if waiting_orders and Input.is_action_just_pressed("escape"):
		waiting_orders =  false
		$Control.visible = false


func _physics_process(_delta: float) -> void:
	if Globals.stage == "fight":
		if mouse_inside and not Input.is_action_pressed("middle-mouse") and not waiting_orders:
			$Area3D/MeshInstance3D.visible = true
		elif not waiting_orders:
			$Area3D/MeshInstance3D.visible = false
		if waiting_orders and not $Area3D/AnimationPlayer.is_playing():
			$Area3D/AnimationPlayer.play("ready")


func _on_mouse_entered() -> void:
	mouse_inside = true


func _on_mouse_exited() -> void:
	mouse_inside = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("finished")
	if anim_name == "ready":
		$Area3D/AnimationPlayer.play("waiting")
