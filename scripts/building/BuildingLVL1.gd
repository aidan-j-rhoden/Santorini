extends Spatial
onready var level2 = preload("res://buildings/BuildingLVL2.tscn")

func _ready():
	randomize()
	if randi() % 2 == 0:
		var lvl2 = level2.instance()
		self.add_child(lvl2, true)
		lvl2.global_transform.origin = $Node2/next_level.global_transform.origin
		lvl2.rotation_degrees = Vector3(0, randi() % 4 * 90, 0)
