extends CanvasLayer

@export var crosshair_color:Color = Color(1, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in $Crosshair.get_children():
		child.color = crosshair_color


func update_crosshair_color():
	for child in $Crosshair.get_children():
		child.color = crosshair_color


func update_crosshair_thickness(value):
	var adjustment = value/2 * -1
	$Crosshair/top.size.x = value
	$Crosshair/top.position.x = adjustment

	$Crosshair/bottom.size.x = value
	$Crosshair/bottom.position.x = adjustment

	$Crosshair/left.size.y = value
	$Crosshair/left.position.y = adjustment

	$Crosshair/right.size.y = value
	$Crosshair/right.position.y = adjustment

	$Crosshair/center.size = Vector2(value, value)
	$Crosshair/center.position = Vector2(adjustment, adjustment)


func _on_r_slider_value_changed(value: float) -> void:
	update_crosshair_color()
	crosshair_color.r = remap(value, 0, 255, 0, 1)


func _on_g_slider_value_changed(value: float) -> void:
	update_crosshair_color()
	crosshair_color.g = remap(value, 0, 255, 0, 1)


func _on_b_slider_value_changed(value: float) -> void:
	update_crosshair_color()
	crosshair_color.b = remap(value, 0, 255, 0, 1)


func _on_thickness_value_changed(value: float) -> void:
	update_crosshair_thickness(value)


func _on_sensitivity_value_changed(value: float) -> void:
	get_parent().CAMERA_ROT_SPEED = remap(value, 1, 100, 0.075, 0.4)
