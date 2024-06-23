extends Node3D
@onready var Building = preload("res://buildings/building.tscn")

var level:int = 0
var mouse_inside:bool = false

func _ready() -> void:
	$Guide/MeshInstance3D.visible = false


func _on_mouse_entered() -> void:
	mouse_inside = true


func _on_mouse_exited() -> void:
	mouse_inside = false


func _physics_process(_delta: float) -> void:
	if mouse_inside and not Input.is_action_pressed("middle-mouse"):
		$Guide/MeshInstance3D.visible = true
	else:
		$Guide/MeshInstance3D.visible = false
	if $Guide/MeshInstance3D.visible:
		if Input.is_action_just_pressed("left-mouse"):
			move_up()


func move_up():
	if level == 0:
		create_building()
		$Guide.position += Vector3(0.0249, 6.0, -0.1762)
		$Guide.scale = Vector3(0.57, 1, 0.55)
	elif level == 1:
		get_node("building").get_node("Lvl1").get_node("Lvl2").visible = true
		get_node("building").get_node("Lvl1").get_node("Lvl2").get_node("Lvl3").visible = false
		$Guide.position += Vector3(0.1, 4.3, -0.0)
		$Guide.scale = Vector3(0.47, 1, 0.47)
	elif level == 2:
		get_node("building").get_node("Lvl1").get_node("Lvl2").get_node("Lvl3").visible = true
		get_node("building").get_node("Lvl1").get_node("Lvl2").get_node("Lvl3").get_node("Lvl4").visible = false
		$Guide.position += Vector3(0.0, 3.4, 0.2)
		$Guide.scale = Vector3(0.3, 0.8, 0.3)
	elif level == 3:
		get_node("building").get_node("Lvl1").get_node("Lvl2").get_node("Lvl3").get_node("Lvl4").visible = true
	level += 1
	if level > 3:
		$Guide.visible = false


func create_building():
	var building = Building.instantiate()
	add_child(building, true)
	building.global_position = self.global_position
	building.rotation_degrees.y = randi_range(0, 3) * 90
