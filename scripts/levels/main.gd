extends Spatial

onready var level1 = preload("res://buildings/BuildingLVL1.tscn")

func _ready():
	for x in range(floor((Settings.width/2)) * -1, Settings.width - floor(Settings.width/2)):
		for z in range(floor((Settings.length/2)) * -1, Settings.length - floor(Settings.length/2)):
			randomize()
			if randi() % 2  == 0:
				var lvl1 = level1.instance()
				lvl1.translation = Vector3(x * 15, 0, z * 15)
				lvl1.rotation_degrees = Vector3(0, randi() % 4 * 90, 0)
				add_child(lvl1, true)
	if Settings.have_floor:
		pass
	else:
		$floor.queue_free()
