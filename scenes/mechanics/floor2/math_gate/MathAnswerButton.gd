extends Node2D
class_name MathAnswerButton

@export var choice_index: int = 0
@export var puzzle_path: NodePath

@export var interaction_area_path: NodePath
@export var ia_collision_path: NodePath
@export var label_path: NodePath

@onready var puzzle: MathGatePuzzle = get_node(puzzle_path) as MathGatePuzzle
@onready var interaction_area: InteractionArea = get_node(interaction_area_path) as InteractionArea
@onready var ia_shape: CollisionShape2D = get_node(ia_collision_path) as CollisionShape2D
@onready var label: Label = get_node_or_null(label_path)

var can_press := false

func _ready() -> void:
	if puzzle == null or interaction_area == null or ia_shape == null:
		push_error("MathAnswerButton: NodePath belum diisi benar di Inspector.")
		return

	interaction_area.interact = Callable(self, "_on_interact")

	puzzle.session_started.connect(_on_started)
	puzzle.session_failed.connect(_on_failed)
	puzzle.session_solved.connect(_on_solved)
	puzzle.question_changed.connect(_on_question_changed)

	_set_pressable(false)

func _on_interact() -> void:
	if not can_press:
		return
	puzzle.submit_choice(choice_index)

func _on_started() -> void:
	_set_pressable(true)

func _on_failed(_reason: String) -> void:
	_set_pressable(false)

func _on_solved() -> void:
	_set_pressable(false)

func _on_question_changed(_q: String, choices: Array[int], _correct_idx: int) -> void:
	if label and choice_index >= 0 and choice_index < choices.size():
		label.text = str(choices[choice_index])

func _set_pressable(v: bool) -> void:
	can_press = v
	interaction_area.set_deferred("monitoring", v)
	interaction_area.set_deferred("monitorable", v)
	ia_shape.disabled = not v
