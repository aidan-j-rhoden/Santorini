extends Node3D

@onready var building = preload("res://buildings/building.tscn")
@onready var player = preload("res://player/player.tscn")
@onready var Camera = preload("res://player/camera_controller.tscn")
@onready var guide = preload("res://buildings/Guide.tscn")

func _ready():
	if Settings.gamemode == 0:
		$Grid.visible = false
		get_node("Players").add_child(player.instantiate())
		for x in range(floor((Settings.width/2.0)) * -1, Settings.width - floor(Settings.width/2.0)):
			for z in range(floor((Settings.length/2.0)) * -1, Settings.length - floor(Settings.length/2.0)):
				if randi() % 2  == 0:
					var level = building.instantiate()
					level.position = Vector3(x * 15, 0, z * 15)
					level.rotation_degrees = Vector3(0, randi() % 4 * 90, 0)
					get_node("Buildings").add_child(level, true)

	if Settings.gamemode == 1:
		build_guides()
		$Cameras.add_child(Camera.instantiate())
		#for x in range(floor((Settings.width/2.0)) * -1, Settings.width - floor(Settings.width/2.0)):
			#for z in range(floor((Settings.length/2.0)) * -1, Settings.length - floor(Settings.length/2.0)):
				#randomize()
				#if randi() % 2  == 0:
					#var level = building.instantiate()
					#level.position = Vector3(x * 15, 0, z * 15)
					#level.rotation_degrees = Vector3(0, randi() % 4 * 90, 0)
					#get_node("Buildings").add_child(level, true)


func build_guides():
	for x in range(floor((Settings.width/2.0)) * -1, Settings.width - floor(Settings.width/2.0)):
			for z in range(floor((Settings.length/2.0)) * -1, Settings.length - floor(Settings.length/2.0)):
				var guide_instance = guide.instantiate()
				guide_instance.position = Vector3(x * 15, 0, z * 15)
				guide_instance.rotation_degrees = Vector3(0, randi() % 4 * 90, 0)
				get_node("Guides").add_child(guide_instance, true)
