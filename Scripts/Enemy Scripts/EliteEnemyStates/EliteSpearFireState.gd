class_name EliteSpearFireState
extends EnemyState

@export var return_state: EnemyState
@export var knockback_force: float = 800.0
@export var spear_damage: float = 35.0
@export var telegraph_length: float = 1000.0
@export var telegraph_width: float = 30.0

var telegraph: SpearTelegraph
var fire_direction: Vector2 = Vector2.RIGHT


func enter() -> void:
	super()
	_fire()


func _fire() -> void:
	if parent.target == null:
		return
	## Check if player is inside the telegraph rectangle
	var to_player := parent.target.global_position - parent.global_position
	var fire_sound := parent.get_node_or_null("SpearFireSound")
	if fire_sound:
		fire_sound.play()
	## Project player position onto fire direction
	var forward_dist := to_player.dot(fire_direction)
	## Get perpendicular distance
	var perp := to_player - fire_direction * forward_dist
	var perp_dist := perp.length()

	var in_telegraph := (
		forward_dist >= 0 and
		forward_dist <= telegraph_length and
		perp_dist <= telegraph_width / 2.0
	)

	if in_telegraph:
		parent.target.modify_current_player_health(-int(spear_damage))
		## Apply knockback in fire direction
		_apply_knockback(parent.target)

	## Hide telegraph
	if telegraph and is_instance_valid(telegraph):
		telegraph.hide_telegraph()


func _apply_knockback(player: PlayerCharacter) -> void:
	## Add knockback velocity — works with your existing physics
	player.velocity += fire_direction * knockback_force


func process_frame(_delta: float) -> EnemyState:
	## Return immediately after firing
	return return_state


func exit() -> void:
	pass
