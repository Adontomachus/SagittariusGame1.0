extends Area2D
enum ProjectileSide {
	Player,
	Enemy
}

@export var projectileSide = ProjectileSide.Player
var projectileVelocity
# Measured in seconds
var projectileLifetime


func _ready():
	projectileVelocity = 762
	projectileLifetime = 50
	return
	
func _process(delta):
	projectileLifetime -= 60 * delta
	if (projectileLifetime < 0):
		queue_free()
func _physics_process(delta):
	position += transform.x * projectileVelocity * delta
		
func _on_area_entered(area: Area2D) -> void:
	if (projectileSide == ProjectileSide.Player):
		if (area.is_in_group("EnemyObject")):
			queue_free()
	if (projectileSide == ProjectileSide.Enemy):
		if (area.is_in_group("PlayerObject")):
			queue_free()
	if (area.is_in_group("MapObstacle")):
		queue_free()
	pass # Replace with function body.
