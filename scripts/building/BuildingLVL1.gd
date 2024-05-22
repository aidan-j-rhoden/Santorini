extends Node3D
@onready var level2 = preload("res://buildings/BuildingLVL2.tscn")
@onready var main = $"/root/menu/level"

func _ready():
	randomize()
	if randi() % 2 == 0:
		var lvl2 = level2.instantiate()
		self.add_child(lvl2, true)
		lvl2.global_transform.origin = $Node2/next_level.global_transform.origin
		lvl2.rotation_degrees = Vector3(0, randi() % 4 * 90, 0)
	randomize()
