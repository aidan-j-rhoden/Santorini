extends CharacterBody3D

const CAMERA_ROT_SPEED = 0.2
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera = $Camera3D
var xrot = 0.0
var yrot = 0.0

var crouched:bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if event is InputEventMouseMotion:
		xrot += float(-event.relative.y) * CAMERA_ROT_SPEED
		yrot += float(-event.relative.x) * CAMERA_ROT_SPEED
		camera.rotation_degrees.x = clamp(xrot, -80, 89.9)
		self.rotation_degrees.y = yrot 
	if Input.is_action_just_pressed("Crouch"):
		if not crouched:
			$AnimationPlayer.play("Crouch")
			crouched = true
		else:
			$AnimationPlayer.play_backwards("Crouch")
			crouched = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
