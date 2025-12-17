extends Node2D

# Call interaction area
@onready var interaction_area: InteractionArea = $InteractionArea

# Call interaction manager and assign the command
func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	
	
# Call dialogoe manager
func _on_interact():
	SceneManager.change_scene("res://scenes/floors/Floor1_Awakening.tscn")
