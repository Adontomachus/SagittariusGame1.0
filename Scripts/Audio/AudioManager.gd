extends AudioStreamPlayer

# AUDIO VARIABLES TEST
var startTime
var delayTime

var songposition:float = 0
var songbpm = 120
var songbps = 60 / songbpm

var notesPassed = 0
var timer = 0

func _ready():
	startTime = Time.get_ticks_usec()
	delayTime = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()

func _process(delta):
	songposition = get_playback_position() + AudioServer.get_time_since_last_mix()

	#print(delayTime)
	
	# This is for temporary testing purposes using Delta time. For this part, we would be first going to test incrementing passed notes by
	# 1 for every second using the delta timer. This could give insights on how to implement pulsing environment to the game music's tempo
	# before using Godot's Audio Stream Player.
	timer += delta
	#print(timer)
	return
