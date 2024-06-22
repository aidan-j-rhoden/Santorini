extends CharacterBody3D

const CAMERA_ROT_SPEED = 0.2
const SPEED = 5.0
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.5
const CROUCH_JUMP_VELOCITY = 2.5

var top_fall_speed = 0.0
var health = 100.0
var dead:bool = false

#hud stuff
@onready var healthbar = $HUD/Health

@onready var camera = $Camera3D
var xrot = 0.0
var yrot = 0.0

var crouched:bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if not dead:
		if event is InputEventMouseMotion:
			xrot += float(-event.relative.y) * CAMERA_ROT_SPEED
			yrot += float(-event.relative.x) * CAMERA_ROT_SPEED
			camera.rotation_degrees.x = clamp(xrot, -80, 89.9)
			self.rotation_degrees.y = yrot 


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		print(velocity.y)
		if abs(velocity.y) > top_fall_speed:
			top_fall_speed = abs(velocity.y)
	else:
		if top_fall_speed != 0.0:
			if top_fall_speed > 14.0:
				damage(100)
			elif top_fall_speed > 9:
				damage(remap(clamp(top_fall_speed - JUMP_VELOCITY, 0, INF), 0, 12, 0, 100))
			elif 7.3 < top_fall_speed and top_fall_speed < 7.6:
				damage(randi_range(1, 5))
			elif 7.6 < top_fall_speed and top_fall_speed < 9.0:
				damage(remap(clamp(top_fall_speed - JUMP_VELOCITY, 0, INF), 0, 15, 0, 30))
			top_fall_speed = 0.0

	if not dead:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			if crouched:
				velocity.y += CROUCH_JUMP_VELOCITY
			else:
				velocity.y += JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			if not crouched:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = direction.x * CROUCH_SPEED
				velocity.z = direction.z * CROUCH_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		if Input.is_action_just_pressed("Crouch"):
			if not crouched:
				$AnimationPlayer.play("Crouch")
				crouched = true
			else:
				$AnimationPlayer.play_backwards("Crouch")
				crouched = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _process(_delta: float) -> void:
	healthbar.value = health
	if health <= 0:
		die()


func damage(amount):
	health -= amount


func die():
	if not dead:
		dead = true
		$HUD/DeathRect.visible = true
		$HUD/DeathRect/AnimationPlayer.play("die")
