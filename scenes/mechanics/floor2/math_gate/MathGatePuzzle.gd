extends Node
class_name MathGatePuzzle

signal session_started()
signal session_failed(reason: String)
signal session_solved()
signal question_changed(question: String, choices: Array[int], correct_index: int)

@export var puzzle_index: int = 1

@export var question_label_path: NodePath
@export var progress_label_path: NodePath
@export var result_label_path: NodePath

@onready var question_label: Label = get_node_or_null(question_label_path)
@onready var progress_label: Label = get_node_or_null(progress_label_path)
@onready var result_label: Label = get_node_or_null(result_label_path)

var rng := RandomNumberGenerator.new()

var running := false
var solved := false

var current_question := ""
var current_choices: Array[int] = []
var correct_choice_index := 0

func _ready() -> void:
	rng.randomize()
	_render_idle()

func start_session() -> void:
	if solved or running:
		return

	running = true
	emit_signal("session_started")
	_next_question()

func submit_choice(choice_index: int) -> void:
	if not running or solved:
		return

	if choice_index == correct_choice_index:
		_render_result(true)
		_solve()
	else:
		_fail("wrong_answer")

func _next_question() -> void:
	var q: Dictionary = _generate_tricky_question()
	current_question = q["text"]
	current_choices = q["choices"]
	correct_choice_index = q["correct_index"]

	_render_question()
	emit_signal("question_changed", current_question, current_choices, correct_choice_index)

func _fail(reason: String) -> void:
	running = false
	_render_result(false)
	_render_idle()
	emit_signal("session_failed", reason)

func _solve() -> void:
	running = false
	solved = true
	_render_solved()
	GameState.floor2_mark(puzzle_index)
	emit_signal("session_solved")

func _render_idle() -> void:
	if question_label:
		question_label.text = "INTERACT BOARD TO START"
	if progress_label:
		progress_label.text = ""
	if result_label:
		result_label.text = ""

func _render_question() -> void:
	if question_label:
		question_label.text = current_question
	if progress_label:
		progress_label.text = "1/1"
	if result_label:
		result_label.text = ""

func _render_result(ok: bool) -> void:
	if not result_label:
		return
	result_label.text = "BENAR" if ok else "SALAH"

func _render_solved() -> void:
	if question_label:
		question_label.text = "SOLVED"
	if progress_label:
		progress_label.text = "1/1"
	if result_label:
		result_label.text = ""

func _generate_tricky_question() -> Dictionary:
	var mode := rng.randi_range(0, 1)

	var a := 0
	var b := 0
	var c := 0
	var correct := 0
	var wrongs: Array[int] = []
	var text := ""

	if mode == 0:
		a = rng.randi_range(2, 18)
		b = rng.randi_range(2, 9)
		c = rng.randi_range(2, 9)

		correct = a + (b * c)
		text = "%d + %d × %d = ?" % [a, b, c]

		wrongs.append((a + b) * c)
		wrongs.append((a * b) + c)
		wrongs.append(a + b + c)
	else:
		a = rng.randi_range(12, 40)
		b = rng.randi_range(2, 9)
		c = rng.randi_range(2, 9)

		if a - (b * c) < 0:
			a = b * c + rng.randi_range(1, 12)

		correct = a - (b * c)
		text = "%d - %d × %d = ?" % [a, b, c]

		wrongs.append((a - b) * c)
		wrongs.append(a - b - c)
		wrongs.append((a * b) - c)

	var unique := {}
	unique[correct] = true

	var cleaned_wrongs: Array[int] = []
	for w in wrongs:
		if w < 0:
			continue
		if unique.has(w):
			continue
		unique[w] = true
		cleaned_wrongs.append(w)

	while cleaned_wrongs.size() < 3:
		var d := rng.randi_range(-6, 6)
		if d == 0:
			continue
		var cand := correct + d
		if cand < 0:
			continue
		if unique.has(cand):
			continue
		unique[cand] = true
		cleaned_wrongs.append(cand)

	var choices: Array[int] = [correct, cleaned_wrongs[0], cleaned_wrongs[1], cleaned_wrongs[2]]
	choices.shuffle()

	var correct_index := choices.find(correct)

	return {
		"text": text,
		"choices": choices,
		"correct_index": correct_index
	}
