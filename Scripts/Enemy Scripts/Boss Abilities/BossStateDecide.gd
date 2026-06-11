class_name BossStateDecide
extends EnemyState

@export var barrage_state: BossStateBarrage
@export var aoe_state: BossStateAoE
@export var summon_state: BossStateSummon

## Weights — higher = more likely. Adjust per phase
@export var barrage_weight: float = 1.0
@export var aoe_weight: float = 1.0
@export var summon_weight: float = 1.0


func enter() -> void:
	super()


func process_frame(_delta: float) -> EnemyState:
	## Pick immediately — adjust weights based on remaining HP
	_adjust_weights_for_phase()
	return _weighted_pick()


func _adjust_weights_for_phase() -> void:
	var hp_percent := float(parent.baseHealthPoints) / float(parent.maxHealthPoints)

	if hp_percent < 0.5:
		## Below 50% HP — more aggressive
		barrage_weight = 1.5
		aoe_weight = 1.5
		summon_weight = 0.5
	if hp_percent < 0.25:
		## Below 25% HP — almost pure barrage and aoe
		barrage_weight = 2.0
		aoe_weight = 2.0
		summon_weight = 0.2


@export var positioning_state: BossStatePositioning

func _weighted_pick() -> EnemyState:
	var total := barrage_weight + aoe_weight + summon_weight
	var roll := randf() * total

	if roll < barrage_weight:
		return barrage_state
	elif roll < barrage_weight + aoe_weight:
		return aoe_state
	else:
		return summon_state



func exit() -> void:
	pass
