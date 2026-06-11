class_name UpdatedBossHealthInterface
extends TextureProgressBar

var boss: Enemy


func _ready():
	add_to_group("BossHealthUI")
	visible = false
	
# Signals for updating the boss health UI #
func _on_boss_update_current_health_value(boss_health: int) -> void:
	value = boss_health


func _on_boss_update_max_health_value(max_boss_health: int) -> void:
	max_value = max_boss_health
