extends Node3D

@onready var level1 = preload("res://buildings/BuildingLVL1.tscn")

func _ready():
	for x in range(floor((Settings.width/2.0)) * -1, Settings.width - floor(Settings.width/2.0)):
		for z in range(floor((Settings.length/2.0)) * -1, Settings.length - floor(Settings.length/2.0)):
			randomize()
			if randi() % 2  == 0:
				var lvl1 = level1.instantiate()
				lvl1.position = Vector3(x * 15, 0, z * 15)
				lvl1.rotation_degrees = Vector3(0, randi() % 4 * 90, 0)
				add_child(lvl1, true)
	if Settings.have_floor:
		pass
	else:
		$floor.queue_free()
