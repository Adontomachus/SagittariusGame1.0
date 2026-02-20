# TEMPORARY SCRIPT
class_name BossHealthInterface
extends ProgressBar

func _ready():
	return

func _process(delta):
	var bossUnit = get_tree().get_first_node_in_group("BossType")
	if !bossUnit:
		self.visible = false
	else:
		self.visible = true
	return
