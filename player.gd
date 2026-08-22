extends Node3D
const move_dist : float = 1
const move_frame_count : float = 10
const dist_by_frame : float = move_dist / move_frame_count

enum state_player {NOP, PLAYER1, PLAYER2, PLAYER3, PLAYER4}
var state = state_player.NOP


const STATE_DIRECTIONS := {
	state_player.NOP: Vector3.ZERO,
	state_player.PLAYER1: Vector3.BACK,    # (0, 0, -1)
	state_player.PLAYER2: Vector3.FORWARD, # (0, 0, 1)
	state_player.PLAYER3: Vector3.RIGHT,   # (1, 0, 0)
	state_player.PLAYER4: Vector3.LEFT,    # (-1, 0, 0)
}

const STATE_ROTATIONS := {
	state_player.NOP: null,
	state_player.PLAYER1: 1.0 * PI,
	state_player.PLAYER2: 2.0 * PI,
	state_player.PLAYER3: 1.5 * PI,
	state_player.PLAYER4: 0.5 * PI,
}

func _ready():
	pass

var cpt = 0
var prev_rot = 0
func _physics_process(delta: float) -> void:

	if state == state_player.NOP :
		if Input.is_action_just_pressed("ui_up") :
			state = state_player.PLAYER1
		if Input.is_action_just_pressed("ui_down") :
			state = state_player.PLAYER2
		if Input.is_action_just_pressed("ui_left") :
			state = state_player.PLAYER3
		if Input.is_action_just_pressed("ui_right") :
			state = state_player.PLAYER4
		if state != state_player.NOP :
			prev_rot = rotation.y 
			
	else :
		
		if cpt == move_frame_count :
			cpt = 0
			
			state = state_player.NOP
			return
		else :
			var step = abs(prev_rot - STATE_ROTATIONS[state]) / move_frame_count
			if step != 0 :
				#var values = range(prev_rot, STATE_ROTATIONS[state], step)
				rotation.y += step
				rotation.y = fmod(rotation.y, TAU)
			
			position += STATE_DIRECTIONS[state] * dist_by_frame
			position = position.snapped(Vector3.ONE * 0.001)
			print(rotation.y)
			cpt += 1
