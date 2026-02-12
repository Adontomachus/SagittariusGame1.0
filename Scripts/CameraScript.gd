extends Camera2D


@onready var playerTarget: CharacterBody2D = $"../Player"

var target
var speed

func _ready():
	pass

func _physics_process(delta):
	# set_global_position(lerp(get_global_position(), playerTarget.get_global_position(), speed))
	if playerTarget:
		position = lerp(position,playerTarget.position, 0.05)
	pass
