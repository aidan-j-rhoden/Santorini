extends Node3D
const CAMERA_ROT_SPEED:float = 0.8
const CAMERA_MOVEMENT_SPEED:float = 0.1

@onready var x_rot = $"Y_Rot/X_Rot"
@onready var y_rot = $Y_Rot
@onready var Camera = $Y_Rot/X_Rot/Camera3D
@onready var Position_Target = $Position_Target

func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("middle-mouse"):
		Position_Target.global_position = y_rot.global_position
		Position_Target.global_rotation = Camera.global_rotation
		if Input.is_action_pressed("shift"):
			# get the angle of the mouse movement relative to the screen
			# then apply that to the camera-controler node location, with the angle paralel to the camera
			var movement_vector:Vector2 = Vector2(event.relative.x, event.relative.y)
			#var distance = sqrt((event.relative.x ** 2) + (event.relative.y ** 2))
			print(movement_vector)
			movement_vector *= CAMERA_MOVEMENT_SPEED * ((Camera.position.z + 1) / 4)

			Position_Target.translate(Vector3(movement_vector.x * CAMERA_MOVEMENT_SPEED, 0, 0))
			Position_Target.translate(Vector3(0, movement_vector.y * CAMERA_MOVEMENT_SPEED, 0))

			y_rot.global_position = Position_Target.global_position
		else:
			y_rot.global_rotation_degrees.y += float(-event.relative.x) * CAMERA_ROT_SPEED
			x_rot.global_rotation_degrees.x = clamp(x_rot.global_rotation_degrees.x + float(-event.relative.y) * CAMERA_ROT_SPEED, -80, 50)

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("zoom-in"):
		Camera.position.z += 50 * delta * ((Camera.position.z + 1) / 4)
	if Input.is_action_just_pressed("zoom-out"):
		Camera.position.z -= 50 * delta * ((Camera.position.z + 1) / 4)
	Camera.position.z = clamp(Camera.position.z, 0, 500)
