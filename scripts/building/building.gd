extends Node3D

func _ready() -> void:
	if randi() % 2 == 0:
		pass
		if randi() % 2 == 0:
			pass
			if randi() % 2 == 0:
				pass
			else:
				$Lvl1/Lvl2/Lvl3/Lvl4.queue_free()
		else:
			$Lvl1/Lvl2/Lvl3.queue_free()
	else:
		$Lvl1/Lvl2.queue_free()
