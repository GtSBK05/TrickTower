extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	if not GameState.floor1_complete():
		return
	SceneManager.change_scene('res://scenes/floors/Floor2_IllusionOfTruth.tscn')
