extends Node2D
class_name SequenceBoard

@export var puzzle_path: NodePath
@export var interaction_area_path: NodePath
@export var ia_collision_path: NodePath

@onready var puzzle: ButtonSequencePuzzle = get_node(puzzle_path) as ButtonSequencePuzzle
@onready var interaction_area: InteractionArea = get_node(interaction_area_path) as InteractionArea
@onready var ia_shape: CollisionShape2D = get_node(ia_collision_path) as CollisionShape2D

func _ready() -> void:
	if puzzle == null or interaction_area == null or ia_shape == null:
		push_error("SequenceBoard: NodePath belum diisi benar di Inspector.")
		return

	interaction_area.interact = Callable(self, "_on_interact")
	puzzle.run_solved.connect(_on_puzzle_solved)

	# kalau puzzle sudah pernah solved (mis. balik ke scene), langsung disable
	if GameState.floor2_puzzles[puzzle.puzzle_index]:
		_disable_board()

func _on_interact() -> void:
	# cegah start ulang kalau sudah solved
	if GameState.floor2_puzzles[puzzle.puzzle_index]:
		_disable_board()
		return

	puzzle.start_run()

func _on_puzzle_solved() -> void:
	_disable_board()

func _disable_board() -> void:
	interaction_area.set_deferred("monitoring", false)
	interaction_area.set_deferred("monitorable", false)
	ia_shape.disabled = true
