extends Node2D


var bgm = preload("res://assets/audio/Medieval Music – Cobblestone Village.wav")
func _ready() -> void:
	BGM.play_music(bgm)