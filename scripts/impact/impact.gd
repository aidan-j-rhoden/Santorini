extends Spatial

class_name Wound


func _ready():
	yield(get_tree().create_timer(10), "timeout")
	#queue_free()
	pass
