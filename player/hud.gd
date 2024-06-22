extends CanvasLayer

@export var crosshair_color:Color = Color(1, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in $Crosshair.get_children():
		child.color = crosshair_color


func update_crosshair_color():
	for child in $Crosshair.get_children():
		child.color = crosshair_color


func _on_r_slider_value_changed(value: float) -> void:
	update_crosshair_color()
	crosshair_color.r = remap(value, 0, 255, 0, 1)


func _on_g_slider_value_changed(value: float) -> void:
	update_crosshair_color()
	crosshair_color.g = remap(value, 0, 255, 0, 1)


func _on_b_slider_value_changed(value: float) -> void:
	update_crosshair_color()
	crosshair_color.b = remap(value, 0, 255, 0, 1)
