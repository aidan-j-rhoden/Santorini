extends Node3D

@onready var level4 = preload("res://buildings/BuildingLVL4.tscn")

func _ready():
	randomize()
	if randi() % 2 == 0:
		var cap = level4.instantiate()
		$next_level.add_child(cap)
