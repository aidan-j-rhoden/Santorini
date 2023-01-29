extends KinematicBody
class_name Player

const CAMERA_ROTATION_SPEED = 0.001
const CAMERA_X_ROT_MIN = -80
const CAMERA_X_ROT_MAX = 80

var camera_x_rot = 0.0
var camera_y_rot = 0.0

var vel = Vector3()
var hvel = Vector2()
var prev_vel = Vector3()
var dir = Vector3()

const GRAVITY = -24.8
const MAX_SPEED = 2
const MAX_SPRINT_SPEED = 6
const JUMP_SPEED = 10
const ACCEL = 5
const SPRINT_ACCEL = 10
const DEACCEL= 5
const AIR_DEACCEL = 1
const MAX_SLOPE_ANGLE = 40
const AIM_HOLD_THRESHOLD = 0.4

# Health
var health setget set_health

# States
var is_grounded = false
var is_sprinting = false
var is_aiming = false
var toggled_aim = false
var current_aim = false
var aiming_timer = 0.0
var is_dead = false
var falling_to_death = false
var is_climbing = false
var is_dancing = false
var is_in_vehicle = false
var weapon_equipped = false
var weapon_name = ""

# Aiming
var camera
var target
var crosshair
var camera_target_initial : Vector3
var crosshair_color_initial : Color
var fov_initial
var fov

#HUD
onready var health_bar = $hud/health
onready var kill_counter = $hud/kill_count
onready var who_killed = $hud/who_killed
onready var death_canvas = $hud/death_canvas
var kill_count = 0
var old_kill_count = 0
onready var game_timer_label = $hud/game_timer_label

# Force
const GRAB_DISTANCE = 50
const THROW_FORCE = 100

# Shape
var shape
var shape_orientation

# Animations
var animation_tree : AnimationTree
var animation_state_machine : AnimationNodeStateMachinePlayback

# Sounds
var air_player
var air_sound
var force_player
var force_shoot
var footsteps_player
var footsteps_concrete
var hit_player
var body_splat
var voice_player
var pain_sound
var win_player
onready var the_win_sound = preload("res://sounds/info/Win_Sound.mp3")

var flying = false

# Gibs
var gibs_scn
onready var main_scn = get_parent()

# Rays
var ray_ground
var ray_ledge_top
var ray_ledge_front
var ray_roof

# Vehicles
var vehicle

# Weapons
var equipped_weapon


func _ready():
	shape = get_node("shape")

	camera = get_node("camera_base/rotation/target/camera")
	target = get_node("camera_base/rotation/target")
	crosshair = get_node("hud/crosshair")

	resize_viewport()
	death_canvas.visible = false

	camera_target_initial = target.transform.origin
	crosshair_color_initial = crosshair.modulate
	fov_initial = camera.fov

	# For facing direction
	shape_orientation = shape.global_transform

	# Animations
	animation_tree = get_node("shape/cube/animation_tree")
	animation_state_machine = animation_tree["parameters/playback"]

	# Sounds
	air_player = get_node("audio/air")
	air_sound = preload("res://sounds/physics/wind.wav")
	air_player.stream = air_sound
	force_player = get_node("audio/force")
	force_shoot = preload("res://sounds/force/force_shoot.wav")
	footsteps_player = get_node("audio/footsteps")
	footsteps_concrete = [
		preload("res://sounds/footsteps/concrete/concrete_1.wav"),
		preload("res://sounds/footsteps/concrete/concrete_2.wav"),
		preload("res://sounds/footsteps/concrete/concrete_3.wav"),
		preload("res://sounds/footsteps/concrete/concrete_4.wav"),
		preload("res://sounds/footsteps/concrete/concrete_5.wav"),
		preload("res://sounds/footsteps/concrete/concrete_6.wav"),
		preload("res://sounds/footsteps/concrete/concrete_7.wav")
	]
	hit_player = get_node("audio/hit")
	body_splat = preload("res://sounds/physics/body_splat.wav")
	voice_player = get_node("audio/voice")
	pain_sound = preload("res://sounds/pain/pain.wav")
	win_player = get_node("audio/win")

	# Gibs
	gibs_scn = preload("res://characters/gibs.tscn")

	# Health
	set_health(100)

	# Rays
	ray_ground = get_node("shape/rays/ground")
	ray_ledge_front = get_node("shape/rays/ledge_front")
	ray_ledge_top = get_node("shape/rays/ledge_top")
	ray_roof = get_node("shape/rays/roof")

	camera.current = true
	crosshair.visible = true

	get_tree().get_root().connect("size_changed", self, "resize_viewport")


func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if not is_dead and Input.is_action_just_pressed("damage"): #Debug only
		kill_count += 1
		hurt(10)
	health_bar.value = health
#	if old_kill_count < kill_count and not win_sound.is_playing():
#		old_kill_count = kill_count
#		win_sound.stream = the_win_sound
#		win_sound.stream.loop = false
#		win_sound.play()
	kill_counter.text = str(kill_count)
	if not is_dead:
		process_input(delta)
	if !is_in_vehicle and not is_dead:
		process_movement(delta)
	process_animations(is_in_vehicle, is_grounded, is_climbing, is_dancing, is_aiming, weapon_equipped, hvel.length(), camera_x_rot, camera_y_rot, delta)
	check_weapons()
	if global_transform.origin.y < -12:
		falling_to_death = true
		die()


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		get_node("camera_base").rotate_y(-event.relative.x * CAMERA_ROTATION_SPEED)
		get_node("camera_base").orthonormalize()
		camera_x_rot = clamp(camera_x_rot + event.relative.y * CAMERA_ROTATION_SPEED, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
		camera_y_rot = clamp(camera_y_rot + event.relative.x * CAMERA_ROTATION_SPEED, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
		get_node("camera_base/rotation").rotation.x = camera_x_rot


func resize_viewport():
	death_canvas.rect_size = get_viewport().size


func process_input(delta):
	# Walking
	dir = Vector3()
	var cam_xform = get_node("camera_base/rotation/target/camera").global_transform

	var input_movement_vector = Vector2()

	if !is_climbing and !is_dead:
		if Input.is_action_pressed("movement_forward"):
			input_movement_vector.y += 1
		if Input.is_action_pressed("movement_backward"):
			input_movement_vector.y -= 1
		if Input.is_action_pressed("movement_left"):
			input_movement_vector.x -= 1
		if Input.is_action_pressed("movement_right"):
			input_movement_vector.x += 1

		input_movement_vector = input_movement_vector.normalized()

		# Basis vectors are already normalized.
		dir += -cam_xform.basis.z * input_movement_vector.y
		dir += cam_xform.basis.x * input_movement_vector.x

		# Sprinting
		if Input.is_action_pressed("sprint"):
			if (weapon_equipped and weapon_name != "heavy") or not weapon_equipped:
				is_sprinting = true
		else:
			is_sprinting = false

		# Jumping
		if is_grounded:
			if Input.is_action_just_pressed("jump"):
				vel.y = JUMP_SPEED

		# Dancing
		if is_grounded:
			if Input.is_action_pressed("dance"):
				is_dancing = true
			if Input.is_action_just_released("dance"):
				is_dancing = false

		# Change weapon
		if Input.is_action_just_released("next_weapon"):
			toggle_weapon()

		# Dealing with weapons
		if equipped_weapon != null:
			if weapon_equipped:
				if (Input.is_action_just_pressed("lmb") and is_aiming) or Input.is_action_pressed("auto_fire") and is_aiming:
					equipped_weapon.fire()
				if Input.is_action_just_pressed("reload"):
					equipped_weapon.reload()
				if Input.is_action_just_pressed("drop"):
					equipped_weapon.drop()

		# Aiming
		var camera_target = camera_target_initial
		var crosshair_alpha = 0.0
		fov = fov_initial

		current_aim = false

		if Input.is_action_just_released("rmb") and aiming_timer <= AIM_HOLD_THRESHOLD:
			current_aim = true
			toggled_aim = true
		else:
			current_aim = toggled_aim or Input.is_action_pressed("rmb")
			if Input.is_action_just_pressed("rmb"):
				toggled_aim = false

		if current_aim:
			aiming_timer += delta
		else:
			aiming_timer = 0.0

		if is_aiming != current_aim:
			is_aiming = current_aim
		if is_aiming and weapon_equipped and equipped_weapon:
			crosshair_alpha = 1.0
			fov = equipped_weapon.fov
			if is_in_vehicle:
				camera.translation = Vector3(0.5, -0.1, 0.2)
				camera_target.z = 0.5
			else:
				camera_target.x = -1.25
		elif !is_aiming and is_in_vehicle:
			camera.translation = Vector3(0, 0, 5)

		target.transform.origin.x += (camera_target.x - target.transform.origin.x) * 0.15
		target.transform.origin.z += (camera_target.z - target.transform.origin.z) * 0.15
		crosshair.modulate.a += (crosshair_alpha - crosshair.modulate.a) * 0.15
		camera.fov += (fov - camera.fov) * 0.15

		# Force
		if is_aiming:
			if !weapon_equipped:
				var space_state = get_world().direct_space_state
				var center_position = get_viewport().size / 2
				var ray_from = camera.project_ray_origin(center_position)
				var ray_to = ray_from + camera.project_ray_normal(center_position) * GRAB_DISTANCE
				var ray_result = space_state.intersect_ray(ray_from, ray_to, [self])
				if ray_result:
					if ray_result.collider:
						var body = ray_result.collider
						if body is RigidBody:
							if Input.is_action_just_pressed("lmb") and is_grounded:
								force_player.stream = force_shoot
								force_player.play()
								body.apply_impulse(Vector3(0, 0, 0), -camera.global_transform.basis.z.normalized() * THROW_FORCE)

	# Cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func process_movement(delta):
	# Ground detection
	if ray_ground.is_colliding() == true:
		is_grounded = true
	else:
		is_grounded = false
	
	# Movement
	dir.y = 0
	dir = dir.normalized()

	if not falling_to_death and not is_climbing:
		vel.y += delta * GRAVITY
	else:
		vel.y = 0

	hvel = vel
	hvel.y = 0

	var target = dir
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
		if not is_on_floor():
			if flying:
				target *= min(translation.y/10, 30)
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
			accel = ACCEL
	else:
		if is_grounded:
			accel = DEACCEL
		else:
			accel = AIR_DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z

	vel = move_and_slide(vel, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	# Face moving direction
	if dir.dot(hvel) > 0:
		var quat_from = Quat(shape_orientation.basis)
		var quat_to = Quat(Transform().looking_at(-dir, Vector3.UP).basis)
		shape_orientation.basis = Basis(quat_from.slerp(quat_to, delta * 10))

	if is_aiming and weapon_equipped and dir.dot(hvel) <= 0:
		# Convert orientation to quaternions for interpolating rotation.
		var q_from = shape_orientation.basis.get_rotation_quat()
		var q_to = $camera_base.global_transform.basis.get_rotation_quat()
		# Interpolate current rotation with desired one.
		shape_orientation.basis = Basis(q_from.slerp(q_to, delta * 10))

	shape.rotation.y = shape_orientation.basis.get_euler().y

	# Ledge detection
	if ray_ledge_front.is_colliding():
		ray_ledge_top.enabled = true
		if ray_ledge_top.is_colliding():
			var ledge_point = ray_ledge_top.get_collision_point() + Vector3(0, 0.5, 0)
			if Input.is_action_just_pressed("jump"):
				ray_roof.enabled = true
				if ray_roof.is_colliding():
					var roof_point = ray_roof.get_collision_point()
					print(roof_point)
					if roof_point.y >= ledge_point.y:
						is_grounded = true
						is_climbing = true
						vel.y = 0
						hvel = Vector2.ZERO
						global_transform.origin = ledge_point
				else:
					is_grounded = true
					is_climbing = true
					vel.y = 0
					hvel = Vector2.ZERO
					global_transform.origin = ledge_point
	else:
		ray_ledge_top.enabled = false
		ray_roof.enabled = false

	# Sounds
	air_player.unit_size = vel.length() / 30
	if !air_player.playing:
		air_player.play()

	if is_on_floor():
		if (vel.length() - prev_vel.length()) < -18:
			print(vel.length() - prev_vel.length())
			hurt(34)
		if (vel.length() - prev_vel.length()) < -24:
			hurt(33)
		if (vel.length() - prev_vel.length()) < -30:
			die()

	prev_vel = vel

# Check for weapons
func check_weapons():
	var weapons = get_node("shape/cube/root/skeleton/bone_attachment/weapon").get_children()
	if weapons.size() > 0:
		equipped_weapon = weapons[0]
		weapon_name = equipped_weapon.title
		if weapon_name == "heavy":
			is_sprinting = false
	else:
		equipped_weapon = null


func toggle_weapon():
	if equipped_weapon != null:
		if weapon_equipped == true:
			weapon_equipped = false
			get_node("shape/cube/root/skeleton/bone_attachment/weapon").visible = false
		else:
			weapon_equipped = true
			get_node("shape/cube/root/skeleton/bone_attachment/weapon").visible = true


# Animations
func process_animations(is_in_vehicle, is_grounded, is_climbing, is_dancing, is_aiming, pistol_equipped, hvel_length, camera_x_rot, camera_y_rot, delta):
	animation_tree["parameters/blend_tree/locomotion/idle_walk_run/blend_position"] = hvel_length
	if !is_grounded and !is_on_floor():
		if vel.y > 0:
			animation_state_machine.travel("jump_up")
		if vel.y == 0:
			animation_state_machine.travel("jump_down")
		if vel.y < 0:
			animation_state_machine.travel("fall")
	else:
		if is_climbing:
			animation_state_machine.travel("climb")
		else:
			if !is_dancing:
				animation_state_machine.travel("blend_tree")
			else:
				animation_state_machine.travel("dance")

	if is_aiming:
		if weapon_equipped:
			if weapon_name == "pistol":
				animation_tree["parameters/blend_tree/pistol_aim_blend/blend_amount"] = 1
				animation_tree["parameters/blend_tree/pistol_aim_dir_x_blend/blend_amount"] = -camera_x_rot
				animation_tree["parameters/blend_tree/pistol_aim_dir_y_blend/blend_amount"] = camera_y_rot
			elif weapon_name == "sniper":
				animation_tree["parameters/blend_tree/pistol_aim_blend/blend_amount"] = 1
				animation_tree["parameters/blend_tree/pistol_aim_dir_x_blend/blend_amount"] = -camera_x_rot
				animation_tree["parameters/blend_tree/pistol_aim_dir_y_blend/blend_amount"] = 0.5
			elif weapon_name == "heavy":
				animation_tree["parameters/blend_tree/pistol_aim_blend/blend_amount"] = 1
				animation_tree["parameters/blend_tree/pistol_aim_dir_x_blend/blend_amount"] = -camera_x_rot
				animation_tree["parameters/blend_tree/pistol_aim_dir_y_blend/blend_amount"] = 0.5
			elif weapon_name == "sword":
				animation_tree["parameters/blend_tree/pistol_aim_blend/blend_amount"] = 1
				animation_tree["parameters/blend_tree/pistol_aim_dir_x_blend/blend_amount"] = -camera_x_rot
				animation_tree["parameters/blend_tree/pistol_aim_dir_y_blend/blend_amount"] = 0.5
		else:
			animation_tree["parameters/blend_tree/aim_blend/blend_amount"] = 1
			animation_tree["parameters/blend_tree/aim_dir_x_blend/blend_amount"] = -camera_x_rot
			animation_tree["parameters/blend_tree/aim_dir_y_blend/blend_amount"] = camera_y_rot
	else:
		if weapon_equipped:
			animation_tree["parameters/blend_tree/pistol_aim_blend/blend_amount"] = 0
		else:
			animation_tree["parameters/blend_tree/aim_blend/blend_amount"] = 0


func set_is_climbing(value):
	is_climbing = value
	update_is_climbing(value)


func update_is_climbing(value):
	is_climbing = value


# Sync position and rotation in the network
func update_trans_rot(pos, rot, shape_rot):
	translation = pos
	rotation = rot
	shape.rotation = shape_rot


func play_random_footstep():
	footsteps_player.unit_size = vel.length()
	footsteps_player.stream = footsteps_concrete[randi() % footsteps_concrete.size()]
	footsteps_player.play()


func hurt(damage):
	set_health(health - damage)
	voice_player.stream = pain_sound
	voice_player.play()


func die():
	if !is_dead:
		death_canvas.visible = true
		$hud/death_canvas/animation_player.play("die")
		kill_count -= 1
		hit_player.stream = body_splat
		hit_player.play()

		current_aim = false
		is_aiming = false
		toggled_aim = false
		aiming_timer = 0.0
		camera.fov = fov_initial
		crosshair.modulate.a = 0.0

		visible = false
		if not falling_to_death:
			# Gibs
			var gibs = gibs_scn.instance()
			main_scn.add_child(gibs)
			gibs.global_transform.origin = global_transform.origin
			for c in gibs.get_children():
				c.apply_impulse(global_transform.origin, c.global_transform.origin - global_transform.origin * 1.1)

		is_dead = true
		get_node("timer_respawn").start()
		get_node("shape").disabled = true
	vel = Vector3(0, 0, 0)


func set_health(value):
	health = value
	if health <= 0:
		die()


# Respawn
func _on_timer_respawn_timeout():
	respawn()


func respawn():
	death_canvas.visible = false
	global_transform.origin = get_parent().get_node("spawn").global_transform.origin
	get_node("shape").disabled = false
	falling_to_death = false
	is_dead = false
	set_health(100)
	vel = Vector3(0, 0, 0)
	visible = true
	for i in self.get_children():
		if i is Wound:
			i.queue_free()


func killed_you(name):
	who_killed.text = name + " killed you!"
	who_killed.visible = true
	yield(get_tree().create_timer(4), "timeout")
	who_killed.visible = false


func create_impact(scn, scn_fx, result, from):
	if scn is EncodedObjectAsID or scn_fx is EncodedObjectAsID:
		return
	var impact = scn.instance()
	self.add_child(impact)
	impact.global_transform.origin = result.position
	impact.global_transform = utils.look_at_with_z(impact.global_transform, result.normal, from)
	randomize()
	impact.rotation = Vector3(impact.rotation.x, impact.rotation.y, rand_range(-180, 180))

	var impact_fx = scn_fx.instance()
	get_tree().root.add_child(impact_fx)
	impact_fx.global_transform.origin = result.position
	impact_fx.emitting = true
	impact_fx.global_transform = utils.look_at_with_x(impact_fx.global_transform, result.normal, from)
