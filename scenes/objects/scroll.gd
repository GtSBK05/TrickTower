extends RigidBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Spawn area bounds
@export_group("Spawn Area")
@export var x_min: float = 100.0
@export var x_max: float = 1000.0
@export var y_min: float = 100.0
@export var y_max: float = 500.0

# Spawn validation settings
@export_group("Spawn Validation")
@export var max_spawn_attempts: int = 50
@export var min_distance_from_wall: float = 32.0
@export var spawn_height_above_ground: float = 48.0  # Height above ground
@export var max_fall_distance: float = 200.0  # Max distance to check for ground
@export var check_player_reachable: bool = true
@export var max_distance_from_player: float = 500.0  # Don't spawn too far

# Other settings
@export_group("Other")
@export var dialogue_resource: DialogueResource

func _ready():
	# Freeze physics
	freeze = true
	
	# Spawn at valid random position
	_spawn_smart_random()
	
	# Play animation
	if animated_sprite:
		animated_sprite.play("default")
	
	# Setup interaction
	if interaction_area:
		interaction_area.interact = Callable(self, "_on_interact")
	else:
		push_error("InteractionArea not found!")

## SMART RANDOM SPAWN - Guaranteed Reachable!
func _spawn_smart_random() -> void:
	var attempts = 0
	var valid_position_found = false
	
	print("=== Starting Smart Spawn ===")
	
	while attempts < max_spawn_attempts and not valid_position_found:
		attempts += 1
		
		# Generate random X position
		var test_x = randf_range(x_min, x_max)
		
		# Find ground at this X position
		var ground_y = _find_ground_at_x(test_x)
		
		if ground_y == -1:
			# No ground found at this X
			continue
		
		# Spawn above ground
		var spawn_pos = Vector2(test_x, ground_y - spawn_height_above_ground)
		
		# Validate this position
		if _is_spawn_position_valid(spawn_pos):
			global_position = spawn_pos
			valid_position_found = true
			print("✅ Scroll spawned at:  ", spawn_pos, " (attempt ", attempts, ")")
			return
	
	# Failed to find valid position
	push_error("❌ Could not find valid spawn position after ", max_spawn_attempts, " attempts!")
	_spawn_fallback()

## Find ground level at given X coordinate
func _find_ground_at_x(x_pos: float) -> float:
	var space_state = get_world_2d().direct_space_state
	
	# Raycast downward from top of spawn area
	var ray_start = Vector2(x_pos, y_min)
	var ray_end = Vector2(x_pos, y_min + max_fall_distance)
	
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.collision_mask = 1  # Ground/platform layer
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result: 
		# Ground found!  
		return result.position.y
	else:
		# No ground found
		return -1

## Validate if spawn position is good
func _is_spawn_position_valid(pos: Vector2) -> bool:
	# Check 1: Not inside wall/obstacle
	if _is_inside_obstacle(pos):
		print("  ❌ Position inside obstacle")
		return false
	
	# Check 2: Not too close to walls
	if not _is_clear_space(pos):
		print("  ❌ Too close to walls")
		return false
	
	# Check 3: Within bounds
	if pos.x < x_min or pos.x > x_max or pos.y < y_min or pos.y > y_max:
		print("  ❌ Outside bounds")
		return false
	
	# Check 4: Not too far from player (optional)
	if check_player_reachable:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var distance = global_position.distance_to(player.global_position)
			if distance > max_distance_from_player: 
				print("  ❌ Too far from player:", distance)
				return false
	
	# All checks passed! 
	return true

## Check if position is inside an obstacle
func _is_inside_obstacle(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1  # Ground/walls layer
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var result = space_state.intersect_point(query, 1)
	return result.size() > 0  # True if inside obstacle

## Check if there's enough clear space around position
func _is_clear_space(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	# Check 4 directions around the spawn point
	var directions = [
		Vector2(min_distance_from_wall, 0),      # Right
		Vector2(-min_distance_from_wall, 0),     # Left
		Vector2(0, -min_distance_from_wall),     # Up
		Vector2(0, min_distance_from_wall)       # Down
	]
	
	for dir in directions:
		var check_pos = pos + dir
		if _is_inside_obstacle(check_pos):
			return false  # Too close to wall
	
	return true  # Enough clear space

## Fallback spawn (near player if possible)
func _spawn_fallback() -> void:
	print("⚠️ Using fallback spawn")
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Spawn near player with offset
		var offset = Vector2(randf_range(-100, 100), -100)
		global_position = player.global_position + offset
		print("Spawned near player at:", global_position)
	else:
		# Last resort: spawn at center of area
		global_position = Vector2((x_min + x_max) / 2, y_min)
		print("Spawned at center:", global_position)

## Interaction
func _on_interact():
	if not dialogue_resource: 
		push_warning("No dialogue resource!")
		_collect_scroll()
		return
	
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	await DialogueManager.dialogue_ended
	_collect_scroll()

func _collect_scroll():
	# Play collect animation if exists
	if animated_sprite and animated_sprite.sprite_frames.has_animation("collect"):
		animated_sprite.play("collect")
		await animated_sprite.animation_finished
	
	# Increment counter
	if GameState: 
		GameState.scroll += 1
		print("Scroll collected!  Total:", GameState.scroll)
	
	# Visual effect before destroy
	_play_collect_effect()
	
	queue_free()

func _play_collect_effect():
	# Tween fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(self, "modulate: a", 0.0, 0.3)
	await tween.finished
