class_name EnemyMeleeCategory
extends Area2D

@export_category("Can Attack")
@export var can_hit_player: bool = true
@export_category("Enemy Variable Getter")
@export var enemy_node: Enemy
@export var melee_effect := preload("res://Objects/Particle Effects/MeleeHitEffect.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	self.area_entered.connect(func(area) -> void:
		if area is PlayerProjectileHitbox: #(area.is_in_group("EnemyObject")):
			if can_hit_player:
				can_hit_player = false
				area.modify_player_health(-enemy_node.attackPower)
				var hitEffect = melee_effect.instantiate()
				hitEffect.position = self.get_global_position()
				get_tree().get_root().call_deferred("add_child", hitEffect)
			return
	)		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
