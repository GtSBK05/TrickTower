extends Node
class_name ButtonSequencePuzzle

signal run_started(sequence: Array[int])
signal run_failed(reason: String)
signal run_solved()

@export var time_limit: float = 12.0
@export var puzzle_index: int = 0 # 0 = ButtonSequencePuzzle, 1 = puzzle kedua

@export var sequence_label_path: NodePath
@export var countdown_label_path: NodePath

@onready var sequence_label: Label = get_node_or_null(sequence_label_path)
@onready var countdown_label: Label = get_node_or_null(countdown_label_path)

const ARROWS: Array[String] = ["↖", "↗", "↙", "↘"] # 0..3

var sequence: Array[int] = []
var step: int = 0
var running: bool = false

@onready var timer: Timer = Timer.new()

func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	_set_ui_idle()

func start_run() -> void:
	if running:
		return

	sequence = [0, 1, 2, 3]
	sequence.shuffle()

	step = 0
	running = true

	timer.start(time_limit)
	_update_ui_running()
	emit_signal("run_started", sequence)

func press_button(button_id: int) -> void:
	if not running:
		return

	if button_id != sequence[step]:
		_fail("wrong_button")
		return

	step += 1
	if step >= sequence.size():
		_solve()
		return

	_update_ui_running()

func _process(_delta: float) -> void:
	if running and countdown_label:
		countdown_label.text = "TIME: %.1f" % timer.time_left

func _on_timeout() -> void:
	_fail("timeout")

func _fail(reason: String) -> void:
	if not running:
		return
	running = false
	timer.stop()
	step = 0
	_set_ui_idle()
	emit_signal("run_failed", reason)

func _solve() -> void:
	running = false
	timer.stop()
	_set_ui_solved()
	GameState.floor2_mark(puzzle_index)
	emit_signal("run_solved")

func _set_ui_idle() -> void:
	if sequence_label:
		sequence_label.text = "INTERACT BOARD TO START"
	if countdown_label:
		countdown_label.text = ""

func _update_ui_running() -> void:
	if not sequence_label:
		return

	var parts: Array[String] = []
	for id in sequence:
		parts.append(ARROWS[id])

	var order_str: String = ""
	for i in range(parts.size()):
		order_str += parts[i]
		if i < parts.size() - 1:
			order_str += " "

	var next_str: String = ARROWS[sequence[step]]
	sequence_label.text = "ORDER: %s | NEXT: %s" % [order_str, next_str]

func _set_ui_solved() -> void:
	if sequence_label:
		sequence_label.text = "SOLVED"
	if countdown_label:
		countdown_label.text = ""
