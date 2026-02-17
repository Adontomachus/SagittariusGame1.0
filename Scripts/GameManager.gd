extends Node2D


@export var beatIndicator: Panel# = $InterfaceElements/HUD/BeatIndicator
var spawnTimer = randf_range(5,10)
@export var player: Node2D# = $"../Player"

# MUSICAL UI
@export var animation_player: AnimationPlayer# = beatIndicator.get_node("AnimationPlayer")

#LEVEL VARIABLES
var level_wave: int = 1
const DIFFICULTY_SCALE: float = 0.15
const DROP_WEIGHT_SCALE: float = 0.05
var difficultyMeter = 1
var pointDropWeight = 0.25
var comboCount = 0
@export var player_target: Marker2D# = $InterfaceElements/PlayerTarget


#SPAWNING VARIABLES
const enemyToSpawn = preload("res://UnitInstances/Enemy.tscn")
var playerSpawnDistance = 200

func _ready():
	#animation_player.play("Pulse")
	pass

#TEMPORARY FUNCTIONS, SUBJECT TO CHANGE	
func _spawnEnemies():
	return

func _nextWave():
	return

func _increaseIncrements():
	return

# SPAWNING WIP #
var randomNumber = randf_range(0,1)

var playerRadius = 300
var instantiationPositions: Vector2

func _process(delta):
	# Spawning Enemies
	spawnTimer -= delta
	if (spawnTimer < 0):
		print("Spawned Enemy!")
		spawnTimer = randf_range(5,6)
		_spawn_enemy()
		
func _spawn_enemy():
	var enemy = enemyToSpawn.instantiate()
	enemy.position = self.global_position
	#if (randomNumber < 0.25):
	#	enemy.unitType = enemy.EnemyType.Normal				
	#else:
	#	enemy.unitType = enemy.EnemyType.Fodder
	#get_tree().get_root().call_deferred("add_child", enemy)
	#spawnTimer = randf_range(5,10)
	add_child(enemy)
