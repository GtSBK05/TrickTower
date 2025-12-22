extends Node2D


var bgm = preload("res://assets/audio/Dark Souls III OST 10 - Vordt of the Boreal Valley.wav")
func _ready() -> void:
	BGM.play_music(bgm)