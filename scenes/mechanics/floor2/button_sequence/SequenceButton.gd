extends Node2D
class_name SequenceButton

@export var button_id: int = 0
@export var puzzle_path: NodePath

# NodePath (isi di Inspector)
@export var interaction_area_path: NodePath
@export var sprite_path: NodePath
@export var ia_collision_path: NodePath

# Anim names (samakan persis dengan SpriteFrames)
@export var anim_idle: StringName = &"Idle"
@export var anim_active: StringName = &"Active"

# Tint + press feedback
@export var idle_tint: Color = Color(1, 1, 1)
@export var active_tint: Color = Color(1, 1, 0.6)
@export var press_offset_y: float = 2.0

var can_press := false
var pressed_this_run := false
var solved := false
var base_pos := Vector2.ZERO

@onready var puzzle: ButtonSequencePuzzle = get_node(puzzle_path) as ButtonSequencePuzzle
@onready var interaction_area: InteractionArea = get_node(interaction_area_path) as InteractionArea
@onready var sprite: AnimatedSprite2D = get_node(sprite_path) as AnimatedSprite2D
@onready var ia_shape: CollisionShape2D = get_node(ia_collision_path) as CollisionShape2D

func _ready() -> void:
	if puzzle == null or interaction_area == null or sprite == null or ia_shape == null:
		push_error("SequenceButton: NodePath belum diisi benar di Inspector.")
		return

	base_pos = sprite.position

	# Sebelum puzzle dimulai: Idle + tidak bisa dipencet
	pressed_this_run = false
	solved = false
	_set_idle_visual()
	_set_pressable(false)

	interaction_area.interact = Callable(self, "_on_interact")

	puzzle.run_started.connect(_on_run_started)
	puzzle.run_failed.connect(_on_run_failed)
	puzzle.run_solved.connect(_on_run_solved)

func _on_run_started(_seq: Array[int]) -> void:
	# Setelah board memulai run: semua tombol Idle + bisa dipencet
	solved = false
	pressed_this_run = false
	sprite.position = base_pos
	_set_idle_visual()
	_set_pressable(true)

func _on_run_failed(_reason: String) -> void:
	# Fail: balik ke Idle + tidak bisa dipencet (harus start ulang via board)
	solved = false
	pressed_this_run = false
	sprite.position = base_pos
	_set_idle_visual()
	_set_pressable(false)

func _on_run_solved() -> void:
	# Solved: tombol jadi Active (tetap Active) + tidak bisa dipencet
	solved = true
	pressed_this_run = true
	sprite.position = base_pos + Vector2(0, press_offset_y)
	_set_active_visual()
	_set_pressable(false)

func _on_interact() -> void:
	# Hanya bisa ditekan saat run aktif dan tombol belum pernah ditekan di run ini
	if not can_press or pressed_this_run or solved:
		return

	# Saat tombol diinteraksi: jadi Active + langsung tidak bisa diinteraksi lagi
	pressed_this_run = true
	sprite.position = base_pos + Vector2(0, press_offset_y)
	_set_active_visual()
	_set_pressable(false)

	# Manager menentukan benar/salah. Kalau salah, run_failed akan reset tombol ke Idle.
	puzzle.press_button(button_id)

func _set_pressable(v: bool) -> void:
	can_press = v
	interaction_area.set_deferred("monitoring", v)
	interaction_area.set_deferred("monitorable", v)
	ia_shape.disabled = not v

func _set_idle_visual() -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_idle):
		sprite.play(anim_idle)
	sprite.modulate = idle_tint

func _set_active_visual() -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_active):
		sprite.play(anim_active)
	_apply_active_color()

# Ubah warna Active di sini (Idle dan Active frame warnanya sama)
func _apply_active_color() -> void:
	sprite.modulate = active_tint
