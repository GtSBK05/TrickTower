extends CanvasLayer

@onready var pause_overlay = $Pause_Overlay
@onready var pause_button = $Pause_Button


func onready () -> void:
	pause_overlay.hide()

func _on_pause_button_pressed() -> void:
	pause_button.texture_normal = load("res://assets/others/play button.png")
	_togle_pause(true)

func _on_resume_button_pressed() -> void:
	pause_button.texture_normal = load("res://assets/others/pause button.png")
	_togle_pause(false)

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")

func _togle_pause(is_paused: bool) -> void:
	get_tree().paused = is_paused
	pause_overlay.visible = is_paused
