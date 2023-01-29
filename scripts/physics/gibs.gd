extends RigidBody

class_name Gibs

var slide
var hit
var roll
var whoosh
export (Array, AudioStreamSample) var HIT
export (AudioStreamSample) var SLIDE
export (AudioStreamSample) var ROLL_SLOW
export (AudioStreamSample) var ROLL_MEDIUM
export (AudioStreamSample) var ROLL_FAST
export (AudioStreamSample) var WHOOSH

export (PackedScene) var particle_scn

var prev_lvl
var lvl
var avl
var avx
var avy
var avz


func _ready():
	hit = get_node("audio/hit")


func _physics_process(delta):
	process_stuff()


func process_stuff():
	lvl = linear_velocity.length()
	avl = angular_velocity.length()
	avx = angular_velocity.x
	avy = angular_velocity.y
	avz = angular_velocity.z

	var bodies = get_colliding_bodies()

	if bodies.size() > 0 and (prev_lvl - lvl) >= 0.25:
		hit.stream = HIT[randi() % HIT.size()]
		hit.play()

	hit.unit_size = lvl

	# Set previous velocity
	prev_lvl = lvl

#	rpc_unreliable("update_trans_rot", translation, rotation)
#
#puppet func update_trans_rot(trans, rot):
#	translation = trans
#	rotation = rot
