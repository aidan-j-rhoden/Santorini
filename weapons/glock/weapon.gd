extends Spatial

export var ray_length = 250
export var knockback_multiplier = 15
export var fire_delay = 0.1
export var bullets = 1
export var spread = 5
export var DAMAGE = 10
export var fov = 60
export var title = "pistol"
var timer_fire = 0
var can_fire = true

# Ammo
export var MAX_AMMO = 160
onready var ammo = 0 setget set_ammo
onready var ammo_supply = 0 setget set_ammo_supply
signal ammo_changed
var is_reloading = false

onready var scn_impact = preload("res://weapons/impact.tscn")
onready var scn_wound = preload("res://weapons/wound.tscn")
onready var scn_impact_fx = preload("res://weapons/impact_fx.tscn")
onready var scn_blood_fx = preload("res://weapons/blood_fx.tscn")

# Muzzle flash
onready var flash = get_node("flash")

# Shooter
var shooter

# States
enum {
	PICKED,
	DROPPED
}

onready var state = DROPPED setget set_state, get_state
signal state_changed

var drop_timeout = 0
var drop_timeout_start = false
var is_pickable = true

onready var main_scn = get_tree().get_root().get_node("menu/level")

func _ready():
	set_ammo(MAX_AMMO)
	set_ammo_supply(MAX_AMMO)

	connect("ammo_changed", self, "_on_ammo_changed")
	connect("state_changed", self, "_on_state_changed")
	get_node("area").connect("body_entered", self, "_on_body_entered")


func _physics_process(delta):
	if timer_fire < fire_delay:
		timer_fire += 1.0 * delta
	if timer_fire > fire_delay:
		can_fire = true
	else:
		can_fire = false

	if ammo <= 0 or is_reloading: 
		can_fire = false

	if state == DROPPED:
		rotation.y += 1.0 * delta
		if rotation.y >= TAU:
			rotation.y = 0

	if drop_timeout_start:
		drop_timeout += 1.0 * delta

	if drop_timeout >= 1:
		is_pickable = true
		drop_timeout_start = false
		drop_timeout = 0


# Fire
func fire():
	if can_fire:
		timer_fire = 0

		set_ammo(ammo - 1)
		get_node("audio/fire").play()
		get_node("animation_player").stop()
		get_node("animation_player").play("fire")

		# Muzzle flash
		flash.rotation.z = rand_range(-180, 180)

		for i in bullets: # Raycast
			var from = shooter.camera.global_transform.origin
			var to = from + (shooter.camera.global_transform.basis.z * -ray_length + random_spread(spread))
			var space_state = get_world().direct_space_state
			var result = space_state.intersect_ray(from, to, [self, shooter])
			if not result.empty():
				print(result.collider)
				if result.collider is Player:
					shooter.get_node("audio/hit").play()
#						result.collider.rpc("killed_you", gamestate.get_player_name())
#					result.collider.rpc_id(1, "hurt", DAMAGE)
#					result.collider.rpc_id(1, "create_impact", "wound", result, shooter.camera.global_transform.basis.z)
					create_impact("wound", result, shooter.camera.global_transform.basis.z)
				if result.collider is RigidBody and not result.collider is Gibs:
					var position = result.position - result.collider.global_transform.origin
					var impulse = (result.position - global_transform.origin).normalized()
					result.collider.apply_impulse(position, impulse * 10)
					create_impact("impact", result, shooter.camera.global_transform.basis.z)
				if result.collider is StaticBody and not result.collider is Gibs:
					create_impact("impact", result, shooter.camera.global_transform.basis.z)
				if result.collider is Gibs:
					var position = result.position - result.collider.global_transform.origin
					var impulse = (result.position - global_transform.origin).normalized()
					result.collider.apply_impulse(position, impulse * 8)
					create_impact("wound", result, shooter.camera.global_transform.basis.z)


# Reloading
func reload():
	if ammo < MAX_AMMO and ammo_supply > 0 and is_reloading != true:
		is_reloading = true
		get_node("animation_player").play("reload")
		get_node("audio/reload").play()
		var ammo_required = MAX_AMMO - ammo
		if ammo_supply >= ammo_required:
			set_ammo_supply(ammo_supply - ammo_required)
			set_ammo(ammo + ammo_required)
		else:
			set_ammo(ammo + ammo_supply)
			set_ammo_supply(0)
		yield(get_node("animation_player"), "animation_finished")
		is_reloading = false


func create_impact(type, result, from):
#	if scn is EncodedObjectAsID or scn_fx is EncodedObjectAsID:
#		return
	var impact
	var impact_fx
	if type == "wound":
		impact = scn_wound.instance()
		impact_fx = scn_blood_fx.instance()
	else:
		impact = scn_impact.instance()
		impact_fx = scn_impact_fx.instance()
	result.collider.add_child(impact)
	impact.global_transform.origin = result.position
	impact.global_transform = utils.look_at_with_z(impact.global_transform, result.normal, from)
	randomize()
	impact.rotation = Vector3(impact.rotation.x, impact.rotation.y, rand_range(-180, 180))

	get_tree().root.add_child(impact_fx)
	impact_fx.global_transform.origin = result.position
	impact_fx.emitting = true
	impact_fx.global_transform = utils.look_at_with_x(impact_fx.global_transform, result.normal, from)


func set_ammo(value):
	ammo = value
	emit_signal("ammo_changed", ammo, ammo_supply)


func set_ammo_supply(value):
	ammo_supply = value
	emit_signal("ammo_changed", ammo, ammo_supply)


func _on_ammo_changed(ammo_value, ammo_supply_value):
	get_node("hud/ammo").text = "AMMO: " + str(ammo_value) + "/" + str(ammo_supply_value)


func set_state(value):
	state = value
	emit_signal("state_changed", value)


func get_state():
	return state


func _on_state_changed(value):
	match value:
		PICKED:
			get_node("animation_player").play("idle")
			get_node("area").monitoring = false
			get_node("area/collision_shape").disabled = true
		DROPPED:
			get_node("animation_player").seek(0, true)
			get_node("animation_player").stop()
			get_node("area").monitoring = true
			get_node("area/collision_shape").disabled = false


func update_trans(trans):
	translation = trans


# Pick up weapon
func _on_body_entered(body):
	shooter = body
	pick()


func pick():
	if shooter != null:
		if shooter is Player and !shooter.is_dead and is_pickable:
			if shooter.equipped_weapon == null:
				var current_ammo = ammo
				var current_ammo_supply = ammo_supply
				is_pickable = false
				var weapon_container = shooter.get_node("shape/cube/root/skeleton/bone_attachment/weapon")
				get_parent().remove_child(self)
				weapon_container.add_child(self)
				transform = Transform.IDENTITY
				set_state(PICKED)
				shooter.weapon_equipped = true
				get_node("hud/ammo").visible = true
				get_node("audio/ammo").play()


# Drop weapon
func drop():
	is_reloading = false
	var current_ammo = ammo
	var current_ammo_supply = ammo_supply
	get_parent().remove_child(self)
	main_scn.add_child(self)
	self.global_transform.origin = shooter.global_transform.origin + shooter.shape_orientation.basis.z * 1.5 + shooter.shape_orientation.basis.x * 1.8
	get_node("hud/ammo").visible = false
	shooter.equipped_weapon = null
	shooter.weapon_equipped = false
	shooter = null
	drop_timeout_start = true
	set_state(DROPPED)


func random_spread(spread_value):
	randomize()
	return Vector3(rand_range(-spread_value, spread_value), rand_range(-spread_value, spread_value), rand_range(-spread_value, spread_value))
