extends Control


var bgm = preload("res://assets/audio/Dark Souls III OST 10 - Vordt of the Boreal Valley.wav")

func _ready():
	BGM.play_music(bgm)

func _on_h_slider_value_changed(value: float) -> void:
	BGM.change_volume(value)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
