extends Node2D


@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D


# Define where the dialogue resource is
var dialogue_resource = load("res://dialogue/resources/test.dialogue")


# Call interaction manager and assign the command
func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
	
# Call dialogoe manager
func _on_interact():
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
