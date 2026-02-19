class_name CameraControl

extends Camera2D


@onready var playerTarget: CharacterBody2D = $"../../Player"

var target
var speed
var cameraShakeEffect = 0
var cameraPosition: Vector2
var camMoveSpeed = 20

var cameraShakeTimer = 1

func _process(delta):
	cameraShakeEffect -= delta
	cameraShakeTimer -= delta
	

func _ready():
	pass

func _physics_process(delta):
	# set_global_position(lerp(get_global_position(), playerTarget.get_global_position(), speed))
	if playerTarget:
		position = lerp(position,playerTarget.position, 0.05)
	if (playerTarget):
		if (cameraShakeEffect > 0):
			cameraPosition = Vector2(playerTarget.global_position.x + randf_range(-6,6), playerTarget.global_position.y + randf_range(-5,5))
		else:
			cameraPosition = playerTarget.global_position
		global_position = global_position.lerp(cameraPosition, delta * camMoveSpeed)
		
	
	pass
	
