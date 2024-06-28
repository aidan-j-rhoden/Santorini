extends Node3D

var mouse_inside:bool = false
var waiting_orders: bool = false

func _ready() -> void:
	$Area3D/MeshInstance3D.visible = false


func _physics_process(delta: float) -> void:
	if mouse_inside and not Input.is_action_pressed("middle-mouse") and not waiting_orders:
		$Area3D/MeshInstance3D.visible = true
	elif not waiting_orders:
		$Area3D/MeshInstance3D.visible = false
	if waiting_orders and not $Area3D/AnimationPlayer.is_playing():
		$Area3D/AnimationPlayer.play("ready")


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left-mouse") and mouse_inside:
		waiting_orders = true
		$Control.visible = true
	if waiting_orders and Input.is_action_just_pressed("escape"):
		waiting_orders =  false
		$Control.visible = false


func _on_mouse_entered() -> void:
	mouse_inside = true


func _on_mouse_exited() -> void:
	mouse_inside = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("finished")
	if anim_name == "ready":
		$Area3D/AnimationPlayer.play("waiting")
