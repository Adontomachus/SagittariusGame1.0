class_name EnemyStateShoot
extends EnemyState

const CHANCE_RANGE: Vector2 = Vector2(0.0, 10.0)
var shot_times: int = 0
@export var attack_telegraph: AnimationPlayer
@export var after_shoot_state: EnemyState



func enter() -> void:
	_check_difficulty()
	super()
	parent.stamina = parent.maxStamina
	shot_times = 0

func process_physics(delta: float) -> EnemyState:
	if (GlobalBeatSync.executeAction):

		if randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) >= parent.successfulChanceToAttack:
			if shot_times == 0:
				attack_telegraph.play("Telegraph")
			shot_times += 1

			
	if shot_times >= 2:
		shot_times = 0
		attack_telegraph.play("Firing")
		parent.shoot_projectile(-24)
		parent.shoot_projectile()
		parent.shoot_projectile(24)
	
	if shot_times >= parent.fire_rate and after_shoot_state:
		return after_shoot_state

	return null

func _check_difficulty() -> void:
	var difficulty_settings = SaveSettings._load_difficulty_settings()
	match difficulty_settings:
		0:
			parent.successfulChanceToAttack = 7.5
		1:
			parent.successfulChanceToAttack = 5
		2:
			parent.successfulChanceToAttack = 0.5
	return
