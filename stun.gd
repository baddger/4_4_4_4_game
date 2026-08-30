extends Node3D

func _ready() -> void:
	var animation_player = $AnimationPlayer
	if animation_player:
		# Get first animation from the player
		var animation_list = animation_player.get_animation_list()
		if animation_list.size() > 0:
			var animation_name = animation_list[0]
			animation_player.play(animation_name)
			animation_player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR
			animation_player.speed_scale = 2.0  # Faster animation (2x speed)
