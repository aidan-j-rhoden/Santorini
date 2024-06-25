extends Node3D

var mouse_inside:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area3D/MeshInstance3D.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if mouse_inside and not Input.is_action_pressed("middle-mouse"):
		$Area3D/MeshInstance3D.visible = true
	else:
		$Area3D/MeshInstance3D.visible = false


func _on_mouse_entered() -> void:
	mouse_inside = true


func _on_mouse_exited() -> void:
	mouse_inside = false
