extends Control

var width:int = 5
var length:int = 5
var have_floor:bool = true
var graphics_level:int = 1

func _on_width_value_changed(value):
	Settings.width = value


func _on_length_value_changed(value):
	Settings.length = value


func _on_check_box_toggled(button_pressed):
	Settings.have_floor = button_pressed


func _on_graphics_level_item_selected(index):
	Settings.graphics_level = index
