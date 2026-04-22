class_name EnemyMeleeCategory
extends Area2D

# Feedback on companion's successful melee
@export var hit_sound: AudioStreamPlayer

@export_category("Can Attack")
@export var can_hit_player: bool = true
@export_category("Enemy Variable Getter")
@export var enemy_node: Enemy
@export var melee_effect := preload("res://Objects/Particle Effects/MeleeHitEffect.tscn")

# Variable for damage number feedback
var enemyDamageNumber := preload("res://Objects/UI Elements/EnemyDamageNumbers.tscn")
# Damage number positioning
var initPosition: Vector2 = Vector2(-225, -205)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	self.area_entered.connect(func(area) -> void:
		if area is PlayerProjectileHitbox: #(area.is_in_group("EnemyObject")):
			##if can_hit_player:
			##	can_hit_player = false
			area.modify_player_health(-enemy_node.attackPower)
			var hitEffect = melee_effect.instantiate()
			hitEffect.position = self.get_global_position()
			var enemyDamageFeedback = enemyDamageNumber.instantiate()
			enemyDamageFeedback.position = self.get_global_position() + initPosition
			enemyDamageFeedback.damage_value = enemy_node.attackPower
			get_tree().get_root().call_deferred("add_child", enemyDamageFeedback)
			hit_sound.play()
			get_tree().get_root().call_deferred("add_child", hitEffect)
		return
	)		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
