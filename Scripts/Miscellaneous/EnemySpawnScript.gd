extends Node


@onready var telegraph: Sprite2D = $Telegraph
## Searches the player's location and repositions the spawn point if its obstructed
var player_target: CharacterBody2D
var p_distance: float = 250
@onready var obstacle_checker: Area2D = $ObstacleChecker


var measuresBeforeSpawning = 4
var beatLifetime = 4
var rarityWeight: float
var eliteRarityWeight: float
var final_wave: bool = false

#COLOR VALUES
var redness = 0

# Const values
const SCALING = preload("res://Scripts/Audio/GameManager.gd")

# Const value for enemy spawn rarities
const CHANCE_RANGE: Vector2 = Vector2(0, 10)

@export var indicator_pulse: AnimationPlayer

@export_category("Enemy Instance to Spawn")
@export var enemyToSpawn = preload("res://UnitInstances/Enemy Instances/Enemy.tscn")
@export var altEnemy = preload("res://UnitInstances/Enemy Instances/EnemyShooter.tscn")
@export var eliteEnemy = preload("res://UnitInstances/Enemy Instances/EliteEnemy.tscn")
@export var chargerEnemy = preload("res://UnitInstances/Enemy Instances/EnemyCharger.tscn")
@export var bossSpawn = preload("res://UnitInstances/Enemy Instances/Boss.tscn")

func _ready() -> void:
	player_target = get_tree().get_first_node_in_group("PlayerObject")
	print("Chance Range: ", CHANCE_RANGE)
	print("Spawning enemy with a rarity weights of: ", rarityWeight)
	

	obstacle_checker.body_entered.connect(func(body: Node2D) -> void:
		if (body.is_in_group("MapObstacle")):
			var randomPosition = Vector2(randf_range(-p_distance,p_distance), randf_range(-p_distance,p_distance))
			self.global_position = self.global_position + randomPosition		
		)
	return
	
func _process(delta: float) -> void:
	redness += 0.4 * delta
	telegraph.modulate = Color(redness * 1.25, 0, 0)
	telegraph.self_modulate = Color(1, 1, 1, 1 + redness * 2)
	
	## Pulse to the beat
	if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
		beatLifetime -= 1
		indicator_pulse.play("Pulse")
		
	## TEMPORARY
	eliteRarityWeight = rarityWeight - 3
	if beatLifetime < 0:
		# This conditional statement checks if rarity value is lower than the chance range
		# If it succeeds, the telegraphed location will spawn an alternate enemy
		# which becomes more commmon on later enemy waves	
		if final_wave:
			_spawn_boss_enemy()
		else:
			if randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) <= rarityWeight - 4:
				_spawn_charger_enemy()
			elif randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) <= rarityWeight - 3:
				_spawn_elite_enemy()
			elif randf_range(CHANCE_RANGE.x, CHANCE_RANGE.y) <= rarityWeight:
				_spawn_alt_enemy()

			else:
				_spawn_enemy()
			return
			

	return

#region Enemy type spawns
func _spawn_enemy():
	var enemy = enemyToSpawn.instantiate()
	enemy.global_position = self.global_position
	get_tree().current_scene.add_child(enemy)
	queue_free()
	return
func _spawn_alt_enemy():
	var enemy = altEnemy.instantiate()
	enemy.global_position = self.global_position
	get_tree().current_scene.add_child(enemy)
	queue_free()
	return
func _spawn_elite_enemy():
	var enemy = eliteEnemy.instantiate()
	enemy.global_position = self.global_position
	get_tree().current_scene.add_child(enemy)
	queue_free()
	return
func _spawn_charger_enemy():
	var enemy = chargerEnemy.instantiate()
	enemy.global_position = self.global_position
	get_tree().current_scene.add_child(enemy)
	queue_free()
	return
func _spawn_boss_enemy():
	var enemy = bossSpawn.instantiate()
	enemy.global_position = self.global_position
	get_tree().current_scene.add_child(enemy)
	queue_free()
	return
	
#endregion
