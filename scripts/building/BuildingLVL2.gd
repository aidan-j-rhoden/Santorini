extends Node3D
var level3 = preload("res://buildings/BuildingLVL3.tscn")
@onready var main = $"/root/menu/level"

func _ready():
	randomize()
	if randi() % 2 == 0:
		var lvl3 = level3.instantiate()
		self.add_child(lvl3, true)
		lvl3.global_transform.origin = $next_level.global_transform.origin
