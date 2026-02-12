extends AudioStreamPlayer

# AUDIO VARIABLES TEST
var startTime
var delayTime

var songposition:float = 0
var songbpm = 120
var songbps = 60 / songbpm

func _ready():
	startTime = Time.get_ticks_usec()
	delayTime = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()

func _process(delta):
	songposition = get_playback_position() + AudioServer.get_time_since_last_mix()
	print(delayTime)
	return
