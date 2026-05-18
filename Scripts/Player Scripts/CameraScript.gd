class_name CameraControl

extends Camera2D

enum CameraMode {
	PlayerView,
	BossView,
	SpawnView,
	CinematicView
}

@export var camera_mode: CameraMode = CameraMode.PlayerView
var camera_focus_target: CharacterBody2D
# @onready var mouse_locator: Marker2D = $"../../MouseLocator"

var cameraShakeEffect = 0
var cameraPosition: Vector2
var camMoveSpeed = 22

var cameraShakeTimer = 1
var cameraShakeStrength = 6
var mousePosition: Vector2

func _process(delta):
	cameraShakeEffect -= delta
	cameraShakeTimer -= delta
	

func _ready():
	#_change_camera_focus_to_boss()
	#await get_tree().create_timer(2).timeout
	_change_camera_focus_to_player()
	
	#var player_target = get_tree().get_first_node_in_group("PlayerObject")
	#camera_focus_target = player_target

	
func _physics_process(delta):
	mousePosition = get_global_mouse_position()
	# set_global_position(lerp(get_global_position(), playerTarget.get_global_position(), speed))
	if camera_focus_target:
		position = lerp(position,camera_focus_target.position + mousePosition / 2, 0.05)
	if (camera_focus_target):
		if (cameraShakeEffect > 0):
			cameraPosition = Vector2(camera_focus_target.global_position.x + randf_range(-cameraShakeStrength,cameraShakeStrength), camera_focus_target.global_position.y + randf_range(-cameraShakeStrength,cameraShakeStrength))
		else:
			cameraPosition = camera_focus_target.global_position
		global_position = global_position.lerp(cameraPosition, delta * camMoveSpeed)
		
func _shake_camera_on_shoot(duration):
	cameraShakeEffect = duration
	return
	
	
func _change_camera_focus_to_boss():
	var boss_target = get_tree().get_first_node_in_group("BossType")
	camera_focus_target = boss_target
	pass
	
func _change_camera_focus_to_player():
	var player_target = get_tree().get_first_node_in_group("PlayerObject")
	camera_focus_target = player_target
	pass
