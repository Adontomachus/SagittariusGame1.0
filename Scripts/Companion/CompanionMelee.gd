class_name CompanionMelee
extends Area2D

@export_category("Can Attack")
## @export var can_hit_enemy: bool = true
@export_category("Enemy Variable Getter")
@export var companion_node: CompanionGroup
@export var melee_effect := preload("res://Objects/Particle Effects/MeleeHitEffect.tscn")
## This variable is to get the position of the enemy target, in order to spawn the damage numbers
@onready var nearest_enemy_target: Marker2D = $"../NearestEnemyTarget"

## Damage numbers section
## Sets the position of the damage number
var initPosition: Vector2 = Vector2(-200, -200)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	self.area_entered.connect(func(area) -> void:
		if area is EnemyProjectileHitbox: #(area.is_in_group("EnemyObject")):

			## Damage number section
			var damageFeedback = companion_node.damageNumber.instantiate()
			damageFeedback.position = self.get_global_position() + initPosition
			damageFeedback.damage_value = companion_node.companion_damage
			get_tree().get_root().call_deferred("add_child", damageFeedback)
			
			area.modify_enemy_health(-companion_node.companion_damage)
			var hitEffect = melee_effect.instantiate()
			hitEffect.position = self.get_global_position()
			get_tree().get_root().call_deferred("add_child", hitEffect)
			
			return
	)		
	
