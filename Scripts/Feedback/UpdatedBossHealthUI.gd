class_name UpdatedBossHealthInterface
extends TextureProgressBar
# TEMPORARY SCRIPT


signal update_max_value(max_health: int)
signal update_current_value(health: int)

func _ready():
	return

func _process(delta):
	# var bossUnit = get_tree().get_first_node_in_group("BossType")
	# if !bossUnit:
#		if "maxHealthPoints" in bossUnit && "healthPoints" in bossUnit:
#			update_max_health_value.emit(bossUnit.maxHealthPoints)
#			update_current_health_value.emit(bossUnit.healthPoints)
	self.visible = false
	#else:
	#	self.visible = true
	return
	
# Function to get the boss unit health points to display on the interface
#func _get_boss_current_health(currentValue, maximumValue):
#	value = currentValue
#	max_value = maximumValue
#	return


#region 
# Signals for updating the boss health UI #
#func _on_boss_update_current_health_value(boss_health: int) -> void:
#	pass # Replace with function body.


#func _on_boss_update_max_health_value(max_boss_health: int) -> void:
#	pass # Replace with function body.
#endregion
