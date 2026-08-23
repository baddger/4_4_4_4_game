extends Node3D

const CAR_SCENE_BLUE = preload("res://car.tscn")
const CAR_SCENE_RED = preload("res://car_red.tscn")
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

		var car_instance = null
		if pipe_color == PipeColor.BLUE :
			car_instance = CAR_SCENE_BLUE.instantiate()
		if pipe_color == PipeColor.RED :
			car_instance = CAR_SCENE_RED.instantiate()

		car_instance.pipe_color = pipe_color
		add_child(car_instance)
