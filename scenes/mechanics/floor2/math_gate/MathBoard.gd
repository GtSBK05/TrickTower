extends Node2D
class_name MathBoard

@export var puzzle_path: NodePath
@export var interaction_area_path: NodePath
@export var ia_collision_path: NodePath

@onready var puzzle: MathGatePuzzle = get_node(puzzle_path) as MathGatePuzzle
@onready var interaction_area: InteractionArea = get_node(interaction_area_path) as InteractionArea
@onready var ia_shape: CollisionShape2D = get_node(ia_collision_path) as CollisionShape2D

func _ready() -> void:
	if puzzle == null or interaction_area == null or ia_shape == null:
		push_error("MathBoard: NodePath belum diisi benar di Inspector.")
		return

	interaction_area.interact = Callable(self, "_on_interact")
	puzzle.session_solved.connect(_disable_board)

	if GameState.floor2_puzzles[puzzle.puzzle_index]:
		_disable_board()

func _on_interact() -> void:
	if GameState.floor2_puzzles[puzzle.puzzle_index]:
		_disable_board()
		return
	puzzle.start_session()

func _disable_board() -> void:
	interaction_area.set_deferred("monitoring", false)
	interaction_area.set_deferred("monitorable", false)
	ia_shape.disabled = true
