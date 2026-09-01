extends CanvasLayer

## Handles the title screen and start countdown.
## Pauses the game during the title screen and countdown. Input is blocked
## in player_multi.gd until the countdown completes.

signal game_started

@onready var title_screen: Control = $TitleScreen
@onready var countdown_label: Label = $CountdownLabel

var _accepting_start_input := true

func _ready() -> void:
#	get_tree().paused = true
	title_screen.visible = true
	countdown_label.visible = false

func _input(event: InputEvent) -> void:
	if not _accepting_start_input:
		return
	if not _is_start_press(event):
		return

	_accepting_start_input = false
	get_viewport().set_input_as_handled()
	title_screen.visible = false
	_run_countdown()

func _is_start_press(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo
	if event is InputEventJoypadButton:
		return event.pressed
	if event is InputEventMouseButton:
		return event.pressed
	return false

func _run_countdown() -> void:
	countdown_label.visible = true
	for step in ["3", "2", "1", "GO"]:
		countdown_label.text = step
		await get_tree().create_timer(1.0).timeout

	countdown_label.visible = false
	# Only unpause once "GO" has been shown, gameplay input is discarded
	# entirely up to this point.
	get_tree().paused = false
	game_started.emit()
