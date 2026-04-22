class_name CompanionMelee
extends Area2D

@export_category("Can Attack")
## @export var can_hit_enemy: bool = true
@export_category("Enemy Variable Getter")
@export var companion_node: CompanionGroup
@export var melee_effect := preload("res://Objects/Particle Effects/MeleeHitEffect.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	self.area_entered.connect(func(area) -> void:
		if area is EnemyProjectileHitbox: #(area.is_in_group("EnemyObject")):
			#if can_hit_enemy:
			#can_hit_enemy = false
			area.modify_enemy_health(-companion_node.attack_power)
			var hitEffect = melee_effect.instantiate()
			hitEffect.position = self.get_global_position()
			get_tree().get_root().call_deferred("add_child", hitEffect)
			return
	)		
	
