extends Node3D
const CAMERA_ROT_SPEED:float = 1.0
const CAMERA_MOVEMENT_SPEED:float = 0.1

@onready var x_rot = $"Y_Rot/X_Rot"
@onready var y_rot = $Y_Rot
@onready var Camera = $Y_Rot/X_Rot/Camera3D
@onready var Position_Target = $Position_Target

func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("middle-mouse"):
		if Input.is_action_pressed("shift"):
			# get the angle of the mouse movement relative to the screen
			# then apply that to the camera-controler node location, with the angle paralel to the camera
			var movement_vector:Vector2 = Vector2(event.relative.x, event.relative.y)
			var distance = sqrt((event.relative.x ** 2) + (event.relative.y ** 2))
			#print(rad_to_deg(movement_vector.angle()))
			print(distance)

			Position_Target.position = y_rot.position
			Position_Target.global_rotation = Camera.global_rotation
			Position_Target.rotation_degrees.x = rad_to_deg(movement_vector.angle())
			#Position_Target.position.z += distance * 0.01

			#y_rot.position = Position_Target.global_position
			y_rot.position.x += float(-event.relative.y) * CAMERA_MOVEMENT_SPEED
			y_rot.position.z += float(-event.relative.x) * CAMERA_MOVEMENT_SPEED
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