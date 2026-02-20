class_name EnemyBoss
extends EnemyCommon

# START
func _ready():
	super()

func _physics_process(delta):
	super(delta)

func recovered_mode() -> void:
	_enemyBehavior = EnemyBehavior.Positioning
