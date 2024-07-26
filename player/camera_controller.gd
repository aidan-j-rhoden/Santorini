extends Node3D
const CAMERA_ROT_SPEED:float = 0.3
const CAMERA_MOVEMENT_SPEED:float = 0.1

@onready var x_rot = $"Y_Rot/X_Rot"
@onready var y_rot = $Y_Rot
@onready var Camera = $Y_Rot/X_Rot/Camera3D
@onready var Position_Target = $Position_Target

@export var player:int

func _ready() -> void:
	$Control/Label.text = "Player " + str(player)
	$Control.visible = false
	Camera.position.z = 20
	x_rot.global_rotation_degrees.x = -20


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("middle-mouse") and Camera.current:
		Position_Target.global_position = y_rot.global_position
		Position_Target.global_rotation = Camera.global_rotation
		if Input.is_action_pressed("shift"):
			# get the angle of the mouse movement relative to the screen
			# then apply that to the camera-controler node location, with the angle paralel to the camera
			var movement_vector:Vector2 = Vector2(-event.relative.x, event.relative.y)
			movement_vector *= CAMERA_MOVEMENT_SPEED * ((Camera.position.z + 1) / 4)

			Position_Target.translate(Vector3(movement_vector.x * CAMERA_MOVEMENT_SPEED, 0, 0))
			Position_Target.translate(Vector3(0, movement_vector.y * CAMERA_MOVEMENT_SPEED, 0))

			y_rot.global_position = Position_Target.global_position
		else:
			y_rot.global_rotation_degrees.y += float(-event.relative.x) * CAMERA_ROT_SPEED
			if y_rot.global_rotation_degrees.y > 360:
				y_rot.global_rotation_degrees.y = 0
			x_rot.global_rotation_degrees.x = clamp(x_rot.global_rotation_degrees.x + float(-event.relative.y) * CAMERA_ROT_SPEED, -80, 50)


func _process(delta: float) -> void:
	if Camera.current:
		$Control.visible = true
		if Input.is_action_just_pressed("zoom-in"):
			Camera.position.z += 50 * delta * ((Camera.position.z + 1) / 4)
		if Input.is_action_just_pressed("zoom-out"):
			Camera.position.z -= 50 * delta * ((Camera.position.z + 1) / 4)
		Camera.position.z = clamp(Camera.position.z, 0, 500)
	else:
		$Control.visible = false


func set_current():
	Camera.current = true
	$Control.visible = true
