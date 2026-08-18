extends Node3D
@export var move_speed : float = 0.1
@export var move_fps : float = 10

enum state_player {NOP, PLAYER1, PLAYER2, PLAYER3, PLAYER4}
var state = state_player.NOP
var moving = false

const STATE_DIRECTIONS := {
	state_player.NOP: Vector3.ZERO,
	state_player.PLAYER1: Vector3.BACK,    # (0, 0, -1)
	state_player.PLAYER2: Vector3.FORWARD, # (0, 0, 1)
	state_player.PLAYER3: Vector3.RIGHT,   # (1, 0, 0)
	state_player.PLAYER4: Vector3.LEFT,    # (-1, 0, 0)
}

func _ready():
	pass

var cpt = 0
func _physics_process(delta: float) -> void:
	position += STATE_DIRECTIONS[state]  * move_speed
	print(position)
	if state != state_player.NOP and cpt != move_fps :
		cpt += 1
	if state != state_player.NOP and cpt == move_fps :
		cpt = 0
		state = state_player.NOP

func _input(event):
	
	if event is InputEventKey and state == state_player.NOP :
		if event.is_action("ui_up") :
			state = state_player.PLAYER1
		if event.is_action("ui_down") :
			state = state_player.PLAYER2
		if event.is_action("ui_left") :
			state = state_player.PLAYER3
		if event.is_action("ui_right") :
			state = state_player.PLAYER4
