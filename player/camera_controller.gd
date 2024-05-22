extends Node3D
const CAMERA_ROT_SPEED:float = 1.0
const CAMERA_MOVEMENT_SPEED:float = 0.1

@onready var x_rot = $"Y_Rot/X_Rot"
@onready var y_rot = $Y_Rot
@onready var Camera = $Y_Rot/X_Rot/Camera3D

func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("middle-mouse"):
		if Input.is_action_pressed("shift"):
			y_rot.position.x += float(-event.relative.y) * CAMERA_MOVEMENT_SPEED
			y_rot.position.z += float(-event.relative.x) * CAMERA_MOVEMENT_SPEED
		else:
			x_rot.global_rotation_degrees.x += float(-event.relative.y) * CAMERA_ROT_SPEED
			y_rot.global_rotation_degrees.y += float(-event.relative.x) * CAMERA_ROT_SPEED

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("zoom-in"):
		Camera.position.z += 50 * delta * ((Camera.position.z + 1) / 4)
	if Input.is_action_just_pressed("zoom-out"):
		Camera.position.z -= 50 * delta * ((Camera.position.z + 1) / 4)
	Camera.position.z = clamp(Camera.position.z, 0, 500)
