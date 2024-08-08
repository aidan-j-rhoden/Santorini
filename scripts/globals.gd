extends Node

@export var stage: String = "setup"
@export var guide_positions: Dictionary = {}

@export var current_player: int = 1
@export var current_worker: Array = [Vector3.INF, 0]
@export var move_here: Array = [Vector3.INF, 0]

@export var p1_worker_positions: Dictionary = {"p1wkr1" = null, "p1wkr2" = null}
@export var p2_worker_positions: Dictionary = {"p2wkr1" = null, "p2wkr2" = null}

@export var moved_and_built: Array = [false, false]

@export var buildable_spaces: int = 0
@export var avalible_spaces: int = 0
