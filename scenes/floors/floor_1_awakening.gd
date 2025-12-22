extends Node2D


var bgm = preload("res://assets/audio/5_minutes____study_timer_work_with_me_cat_on_a_fluffy_cloud_timer_10min____studymusic__lofi.wav")
func _ready() -> void:
	BGM.play_music(bgm)
