extends Control

var width:int = 5
var length:int = 5
var graphics_level:int = 1
var gamemode:int = 0

func _on_width_value_changed(value):
	Settings.width = value


func _on_length_value_changed(value):
	Settings.length = value


func _on_graphics_level_item_selected(index):
	Settings.graphics_level = index
