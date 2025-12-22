extends Control

var bgm = preload("res://assets/audio/Dark Souls III OST 10 - Vordt of the Boreal Valley.wav")

func _ready():
	BGM.play_music(bgm)
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/floors/house/house.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_setting_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/Setting.tscn")
