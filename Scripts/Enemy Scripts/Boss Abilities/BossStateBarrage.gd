class_name BossStateBarrage
extends EnemyState

@export var next_state: EnemyState

@export_category("Barrage Settings")
## How many rings to fire before switching state
@export var rings_to_fire: int = 5
## Beats between each ring
@export var beats_between_rings: int = 3
## How many projectiles per ring
@export var projectiles_per_ring: int = 30
## Size of the gap in degrees — bigger = easier to dodge
@export var gap_size_degrees: float = 20
## Damage per projectile
@export var projectile_damage: float = 20.0

var rings_fired: int = 0
var beats_elapsed: int = 0
var last_beat: float = 0.0
var gap_angle: float = 0.0


func enter() -> void:
	super()
	rings_fired = 0
	beats_elapsed = 0
	last_beat = beat_sync.beat if beat_sync else 0.0
	## Point gap toward player on entry so first ring is always fair
	gap_angle = _get_player_angle()


func process_frame(_delta: float) -> EnemyState:
	if beat_sync == null:
		return null

	var current_beat := beat_sync.beat
	if current_beat > last_beat:
		last_beat = current_beat
		beats_elapsed += 1

		if beats_elapsed >= beats_between_rings:
			beats_elapsed = 0
			_fire_ring()
			rings_fired += 1

			if rings_fired >= rings_to_fire:
				return next_state

	return null


func _fire_ring() -> void:
	## Rotate gap slightly each ring so player has to keep moving
	gap_angle = _get_player_angle() + randf_range(-20.0, 20.0)

	var gap_half := gap_size_degrees / 2.0
	var angle_step := 360.0 / projectiles_per_ring

	for i in range(projectiles_per_ring):
		var angle_deg := i * angle_step
		## Skip projectiles inside the gap window
		var diff := fmod(abs(angle_deg - gap_angle), 360.0)
		if diff > 180.0:
			diff = 360.0 - diff
		if diff <= gap_half:
			continue

		parent.shoot_slow_projectile(angle_deg - parent.shoot_point.rotation_degrees)


func _get_player_angle() -> float:
	if parent.target == null:
		return 0.0
	var dir := parent.target.global_position - parent.global_position
	return rad_to_deg(dir.angle())


func exit() -> void:
	pass
