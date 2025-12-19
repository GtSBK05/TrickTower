extends RigidBody2D


# Call interaction area
@onready var interaction_area: InteractionArea = $InteractionArea

# Export variable for easier use
@export var x_min: float = 0
@export var x_max: float = 0
@export var y1: float = 0
@export var y2: float = 0
@export var dialogue_resource: Resource

# Call interaction manager and assign the command
func _ready():
	# Position the scroll randomly
	randomize()
	var x = randf_range(x_min, x_max)
	var y = y1 if randi() % 2 == 0 else y2
	position = Vector2(x, y)
	# Use intraction manager
	interaction_area.interact = Callable(self, "_on_interact")
	
	
# Call dialogoe manager
func _on_interact():
	# Use dialogue manager
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	# Increment scroll count
	Global.scroll += 1
	# Remove node
	queue_free()
