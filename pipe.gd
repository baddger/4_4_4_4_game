extends Node3D

const CAR_SCENE = preload("res://car.tscn")
const SPAWN_INTERVAL = 2.0

enum PipeColor { BLUE, RED }

@export var pipe_color: PipeColor = PipeColor.BLUE

var _spawn_timer = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_spawn_timer += delta

	if _spawn_timer >= SPAWN_INTERVAL:
		_spawn_timer = 0.0
		var car_instance = CAR_SCENE.instantiate()
		car_instance.position = position
		car_instance.pipe_color = pipe_color
		get_parent().add_child(car_instance)
