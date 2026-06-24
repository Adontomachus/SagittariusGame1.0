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

#region Shake Variables
@export_category("Shake Settings")
@export var decay_rate: float = 2.5
@export var max_offset: Vector2 = Vector2(40.0, 30.0)
@export var max_rotation_degrees: float = 4.0
@export var noise_speed: float = 60.0

var trauma: float = 0.0
var noise_y: float = 0.0
var noise: FastNoiseLite
#endregion

func _process(delta):
	## Decay trauma
	if trauma > 0.0:
		trauma = maxf(trauma - decay_rate * delta, 0.0)
		noise_y += delta * noise_speed

		var shake_amount := trauma * trauma
		offset = Vector2(
			max_offset.x * shake_amount * noise.get_noise_2d(noise_y, 0.0),
			max_offset.y * shake_amount * noise.get_noise_2d(0.0, noise_y)
		)
		rotation_degrees = max_rotation_degrees * shake_amount * noise.get_noise_2d(noise_y, noise_y)
	else:
		offset = Vector2.ZERO
		rotation_degrees = 0.0
	

func _ready():
	#_change_camera_focus_to_boss()
	#await get_tree().create_timer(2).timeout
	_change_camera_focus_to_player()
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 0.5
	
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
		
func _shake_camera_on_shoot(duration) -> void:
	add_trauma(clampf(duration * 0.8, 0.1, 1.0))
	
func add_trauma(amount: float) -> void:
	trauma = minf(trauma + amount, 1.0)
	
	#test
func _change_camera_focus_to_boss():
	var boss_target = get_tree().get_first_node_in_group("BossType")
	camera_focus_target = boss_target
	pass
	
func _change_camera_focus_to_player():
	var player_target = get_tree().get_first_node_in_group("PlayerObject")
	camera_focus_target = player_target
	pass
