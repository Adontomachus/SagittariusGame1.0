class_name CameraControl

extends Camera2D

enum CameraMode {
	PlayerView,
	BossView,
	SpawnView,
	CinematicView
}

@export var camera_mode: CameraMode = CameraMode.PlayerView
@onready var playerTarget: CharacterBody2D = $"../../Player"
@onready var mouse_locator: Marker2D = $"../../MouseLocator"

var cameraShakeEffect = 0
var cameraPosition: Vector2
var camMoveSpeed = 20

var cameraShakeTimer = 1
var mousePosition: Vector2

func _process(delta):
	cameraShakeEffect -= delta
	cameraShakeTimer -= delta
	

func _ready():
	pass

func _physics_process(delta):
	mousePosition = get_global_mouse_position()
	# set_global_position(lerp(get_global_position(), playerTarget.get_global_position(), speed))
	if playerTarget:
		position = lerp(position,playerTarget.position + mousePosition / 2, 0.05)
	if (playerTarget):
		if (cameraShakeEffect > 0):
			cameraPosition = Vector2(playerTarget.global_position.x + randf_range(-6,6), playerTarget.global_position.y + randf_range(-5,5))
		else:
			cameraPosition = playerTarget.global_position
		global_position = global_position.lerp(cameraPosition, delta * camMoveSpeed)
		
func _shake_camera_on_shoot(duration):
	cameraShakeEffect = duration
	return
