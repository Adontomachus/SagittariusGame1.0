class_name AreaOfEffect
extends Node

enum ProjectileSide {
	Player,
	Enemy
}

@export_category("Area of Effect Statistics")
@export var aoe_damage: float = 25
@export var lifetime: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.area_entered.connect(func(area) -> void:
		if area is EnemyProjectileHitbox: #(area.is_in_group("EnemyObject")):
			area.modify_enemy_health(-aoe_damage)
			area.show_aoe_feedback(aoe_damage)
	)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# Function to change damage outside of exported value
func change_damage(damage: int) -> void:
	aoe_damage = damage
