extends CharacterBody2D

const SPEED_WALK = 100.0
const SPEED_RUN = 300.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 1350.0
const LAND_DURATION = 0.15

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_area: Area2D = $InteractArea

var state: String = "Idle"
var land_timer: float = 0.0
var DEBUG_MODE := false
var is_heavy_action = false
var current_target: Node = null
var is_dead: bool = false

func _ready() -> void:
	GameManager.register_player(self)
	
	floor_snap_length = 6.0
	interact_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interact_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	var input_dir = Input.get_axis("move_left", "move_right")
	var is_run_pressed = Input.is_action_pressed("run_enable")

	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y > 0:
			velocity.y += GRAVITY * 0.3 * delta

	if is_on_floor() and Input.is_action_just_pressed("jump") and land_timer <= 0:
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.6

	if input_dir != 0:
		var speed = SPEED_RUN if is_run_pressed else SPEED_WALK
		if is_heavy_action:
			speed *= 0.4
		velocity.x = input_dir * speed
		anim.flip_h = input_dir < 0
	else:
		velocity.x = 0

	var new_state = state

	if land_timer > 0:
		land_timer -= delta
		new_state = "Land"
	else:
		if not is_on_floor():
			if velocity.y < 0:
				new_state = "Jump"
			elif velocity.y > 10:
				new_state = "Fall"
			else:
				new_state = state
		else:
			if state == "Fall":
				new_state = "Land"
				land_timer = LAND_DURATION
			elif is_run_pressed and input_dir != 0:
				new_state = "Run"
			elif input_dir != 0:
				new_state = "Walk"
			else:
				new_state = "Idle"

	if new_state != state:
		state = new_state
		anim.play(state)
		if DEBUG_MODE:
			print(">>> STATE:", state, " | vel=", velocity)

	move_and_slide()

	if Input.is_action_just_pressed("interact"):
		var action_type = _get_interact_action_type()
		if DEBUG_MODE:
			print("Player mencoba berinteraksi:", action_type)
		_handle_interaction(action_type)

func _on_body_entered(body: Node) -> void:
	if body.has_method("trigger"):
		current_target = body
		if DEBUG_MODE:
			print("Target interaktif terdeteksi:", body.name)

func _on_body_exited(body: Node) -> void:
	if current_target == body:
		current_target = null
		if DEBUG_MODE:
			print("Keluar dari area interaksi:", body.name)

func _get_interact_action_type() -> String:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir == 0:
		return "neutral"
	if (anim.flip_h and input_dir < 0) or (not anim.flip_h and input_dir > 0):
		return "push"
	else:
		return "pull"

func _handle_interaction(action_type: String) -> void:
	if current_target and current_target.has_method("trigger"):
		current_target.trigger(action_type)
	else:
		match action_type:
			"push":
				if DEBUG_MODE: print("Aksi: DORONG tanpa target.")
			"pull":
				if DEBUG_MODE: print("Aksi: TARIK tanpa target.")
			"neutral":
				if DEBUG_MODE: print("Aksi: INTERACT netral tanpa target.")

func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	current_target = null
	velocity = Vector2.ZERO
	
	if anim.sprite_frames.has_animation("Dead"):
		anim.play("Dead")
	else:
		anim.play("Idle")
	
	await get_tree().create_timer(0.6).timeout
	GameManager.respawn()
	_revive()

func _revive() -> void:
	is_dead = false
	
	set_physics_process(true)
	set_process(true)
	
	state = "Idle"
	anim.play("Idle")

func _start_heavy_action(anim_name: String) -> void:
	is_heavy_action = true
	velocity.x = 0
	anim.play(anim_name)

	var tween = get_tree().create_tween()
	tween.tween_property(anim, "speed_scale", 0.7, 0.1)
	tween.tween_property(anim, "speed_scale", 1.0, 0.3).set_delay(0.3)

	await get_tree().create_timer(0.6).timeout
	is_heavy_action = false
