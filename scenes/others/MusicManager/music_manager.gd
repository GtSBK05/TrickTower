extends AudioStreamPlayer


var music_bus_index = AudioServer.get_bus_index("Ost")

func play_music(new_stream: AudioStream):
	if stream == new_stream:
		return
	
	stream = new_stream
	play()

func change_volume(value: float):
	var db_value = linear_to_db(value)
	AudioServer.set_bus_volume_db(music_bus_index, db_value)