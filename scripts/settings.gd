extends Control

var width = 5
var length = 5
var have_floor = true

func _on_width_value_changed(value):
	Settings.width = value


func _on_length_value_changed(value):
	Settings.length = value


func _on_check_box_toggled(button_pressed):
	Settings.have_floor = button_pressed
