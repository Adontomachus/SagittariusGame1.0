extends Node


@onready var telegraph: Sprite2D = $Telegraph

var measuresBeforeSpawning = 4
var beatLifetime = 4
var rarityWeight: float
var eliteRarityWeight: float

@export_category("Enemy Statistic Modifiers before Spawn")
@export var unitHealthPoints = 60
@export var maxUnitHealthPoints = 60
@export var unitAttackPower = 14
#COLOR VALUES
var redness = 0

# Const values
const SCALING = preload("res://Scripts/AudioBased/GameManager.gd")

# Const value for enemy spawn rarities
const CHANCE_RANGE: Vector2 = Vector2(0, 10)

@export_category("Enemy Instance to Spawn")
@export var enemyToSpawn = preload("res://UnitInstances/Enemy.tscn")
@export var altEnemy = preload("res://UnitInstances/EnemyShooter.tscn")
@export var eliteEnemy = preload("res://UnitInstances/EliteEnemy.tscn")
@export var bossSpawn = preload("res://UnitInstances/Boss.tscn")

func _ready() -> void:
	print("Chance Range: ", CHANCE_RANGE)
	print("Spawning enemy with a rarity weight of: ", rarityWeight)
	return
	
func _process(delta: float) -> void:
	beatLifetime -= 2 * delta
	redness += 0.4 * delta
	telegraph.modulate = Color(redness,0,0)
	
	#TEMPORARY
	eliteRarityWeight = rarityWeight - 3
	if beatLifetime < 0:
		# This conditional statement checks if rarity value is lower than the chance range
		# If it succeeds, the telegraphed location will spawn an alternate enemy
		# which becomes more commmon on later enemy waves	
		if randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) <= rarityWeight - 3:
			_spawnEliteEnemy()
		elif randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) <= rarityWeight:
			_spawnAltEnemy()
		else:
			_spawnEnemy()
		return
	return

func _spawnEnemy():
	var enemy = enemyToSpawn.instantiate()
	enemy.global_position = self.global_position
	get_tree().current_scene.add_child(enemy)
	queue_free()
	return
func _spawnAltEnemy():
	var enemy = altEnemy.instantiate()
	enemy.global_position = self.global_position
	get_tree().current_scene.add_child(enemy)
	queue_free()
	return
func _spawnEliteEnemy():
	var enemy = eliteEnemy.instantiate()
	enemy.global_position = self.global_position
	get_tree().current_scene.add_child(enemy)
	queue_free()
	return
