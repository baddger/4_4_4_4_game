extends Node3D

const CAR_SCENE = preload("res://car.scn")
const SPAWN_INTERVAL = 2.0

enum PipeColor { BLUE, RED }

@export var pipe_color: PipeColor = PipeColor.BLUE

var _spawn_timer = 0.0


func _ready() -> void:

	for car_number in range(0, 10, 1):
		var car = spaawning()
		for a in range(0, SPAWN_INTERVAL * car_number * Engine.physics_ticks_per_second, 1):
			car._physics_process(1.0 / Engine.physics_ticks_per_second)


func _process(delta: float) -> void:
	_spawn_timer += delta

	if _spawn_timer >= SPAWN_INTERVAL:
		_spawn_timer = 0.0
		spaawning()

func spaawning() -> Node3D:
	var car_instance = CAR_SCENE.instantiate()
	car_instance.pipe_color = pipe_color
	add_child(car_instance)
	return car_instance
