extends Node2D

@export var interaction_area_path: NodePath
@export var switch_anim_path: NodePath
@export var indicator_path: NodePath
@export var ia_collision_path: NodePath

@export var idle_tint: Color = Color(1, 1, 1)       # normal
@export var active_tint: Color = Color(1, 1, 0.6)   # contoh: sedikit kuning
@export var press_offset_y: float = 2.0

@export var indicator_off: Color = Color(1, 0, 0)
@export var indicator_on: Color = Color(0, 1, 0)

var solved := false
var base_pos := Vector2.ZERO

@onready var interaction_area: InteractionArea = get_node(interaction_area_path) as InteractionArea
@onready var switch_anim: AnimatedSprite2D = get_node(switch_anim_path) as AnimatedSprite2D
@onready var indicator: Sprite2D = get_node(indicator_path) as Sprite2D
@onready var ia_shape: CollisionShape2D = get_node(ia_collision_path) as CollisionShape2D

func _ready() -> void:
	if interaction_area == null or switch_anim == null or indicator == null or ia_shape == null:
		push_error("PuzzleSwitch: NodePath belum diisi benar di Inspector.")
		return

	base_pos = switch_anim.position

	switch_anim.modulate = idle_tint
	indicator.modulate = indicator_off

	if switch_anim.sprite_frames and switch_anim.sprite_frames.has_animation("Idle"):
		switch_anim.play("Idle")

	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	if solved:
		return
	solved = true

	if switch_anim.sprite_frames and switch_anim.sprite_frames.has_animation("Active"):
		switch_anim.play("Active")

	switch_anim.modulate = active_tint
	switch_anim.position = base_pos + Vector2(0, press_offset_y)
	indicator.modulate = indicator_on

	interaction_area.set_deferred("monitoring", false)
	interaction_area.set_deferred("monitorable", false)
	ia_shape.disabled = true

	GameState.floor1_mark(0)
