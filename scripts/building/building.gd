extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randi() % 2 == 0:
		$Lvl1/Lvl2.visible = true
		if randi() % 2 == 0:
			$Lvl1/Lvl2/Lvl3.visible = true
			$Lvl1/Lvl2/Lvl3/Lvl4.visible = false
			if randi() % 2 == 0:
				$Lvl1/Lvl2/Lvl3/Lvl4.visible = true
