extends Spatial
var level3 = preload("res://buildings/BuildingLVL3.tscn")


func _ready():
	randomize()
	if randi() % 2 == 0:
		var lvl3 = level3.instance()
		self.add_child(lvl3, true)
		lvl3.global_transform.origin = $next_level.global_transform.origin
