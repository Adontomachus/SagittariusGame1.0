extends Node


@onready var telegraph: Sprite2D = $Telegraph

var measuresBeforeSpawning = 4
var beatLifetime = 4
#COLOR VALUES
var redness = 0
const SCALING = preload("res://Scripts/AudioBased/GameManager.gd")
@export var enemyToSpawn = preload("res://UnitInstances/Enemy.tscn")
@export var altEnemy = preload("res://UnitInstances/EnemyShooter.tscn")
@export var eliteEnemyToSpawn = preload("res://UnitInstances/EliteEnemy.tscn")
@export var bossSpawn = preload("res://UnitInstances/Boss.tscn")

func _ready() -> void:
	return
	
func _process(delta: float) -> void:
	beatLifetime -= 2 * delta
	redness += 0.4 * delta
	telegraph.modulate = Color(redness,0,0)
	if beatLifetime < 0:
		_spawnEnemy()
		return
	return

func _spawnEnemy():
	var enemy = enemyToSpawn.instantiate()
	enemy.global_position = self.global_position
	get_tree().current_scene.add_child(enemy)
	queue_free()
	return
