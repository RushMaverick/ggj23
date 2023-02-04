extends Node2D

func fade_in():
	var tween_in = create_tween()
#	if $DrumLayer2.get_volume_db() > -50:
#		return
	# tween music volume down to 0
	tween_in.tween_property($MusicPlayer/DrumLayer2, "volume_db", 0, 8)
	# when the tween ends, the music will be stopped
