extends Area2D

@onready var plate_anim: AnimatedSprite2D = $PlateSprite
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var top_marker: Marker2D = $TopMarker

@export var idle_anim: StringName = "Idle"
@export var active_anim: StringName = "Active"

# syarat jatuh
@export var min_fall_speed: float = 300.0      # px/s
@export var min_fall_motion: float = 6.0       # px per physics frame (fallback)
@export var above_margin: float = 6.0          # toleransi posisi dari atas

var solved := false

func _ready() -> void:
	monitoring = true
	monitorable = true
	set_physics_process(true)
	plate_anim.play(idle_anim)

func _physics_process(delta: float) -> void:
	if solved:
		return

	var bodies := get_overlapping_bodies()
	if bodies.is_empty():
		return

	for body in bodies:
		if not body.is_in_group("player"):
			continue

		# harus datang dari atas plate (pakai marker sebagai patokan)
		if body.global_position.y > top_marker.global_position.y - above_margin:
			continue

		# harus benar-benar sedang jatuh
		if not _is_falling(body, delta):
			continue

		_solve()
		return

func _is_falling(body: Node, delta: float) -> bool:
	# utama: CharacterBody2D.velocity.y
	if body is CharacterBody2D:
		var cb := body as CharacterBody2D
		if cb.velocity.y >= min_fall_speed:
			return true

		# fallback kalau velocity keburu jadi 0 saat kontak:
		# get_last_motion() = perpindahan per physics frame
		if cb.get_last_motion().y >= min_fall_motion:
			return true

		return false

	# fallback lain kalau player punya API sendiri
	if body.has_method("get_velocity"):
		var v = body.call("get_velocity")
		if v is Vector2:
			return v.y >= min_fall_speed

	return false

func _solve() -> void:
	solved = true
	plate_anim.play(active_anim)

	set_deferred("monitoring", false)
	shape.disabled = true

	GameState.floor1_mark(1)
