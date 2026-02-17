extends Panel
@onready var metronome_test: AudioStreamPlayer2D = $"../MetronomeTest"

var tempo = 120
var pulsePerBeat = 60 / tempo
var lastBeat = 0


func _process(delta):
	# var time = metronome_test.get_playback_position() + AudioServer.get_time_since_last_mix()
	
	#var beat = int(time/pulsePerBeat)
	#if beat > lastBeat:
	#	print("Note passed!")
	#	lastBeat = beat
	return
