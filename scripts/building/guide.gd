extends Node3D

func _ready() -> void:
	$MeshInstance3D.visible = false


func _on_mouse_entered() -> void:
	$MeshInstance3D.visible = true


func _on_mouse_exited() -> void:
	$MeshInstance3D.visible = false


#func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#$MeshInstance3D.visible = true
