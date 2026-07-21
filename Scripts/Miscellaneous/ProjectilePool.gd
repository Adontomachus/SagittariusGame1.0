class_name ProjectilePool
extends Node

var pool: Array[Node2D] = []

func setup(scene: PackedScene, pool_size: int, parent_node: Node) -> void:
	for i in range(pool_size):
		var instance = scene.instantiate()
		# Immediately put it to sleep
		instance.hide()
		instance.set_process(false)
		instance.set_physics_process(false)
		
		# Add to the world exactly once
		parent_node.call_deferred("add_child", instance)
		pool.append(instance)

func get_projectile() -> Node2D:
	for item in pool:
		if not item.visible:
			# Wake the projectile up
			item.set_process(true)
			item.set_physics_process(true)
			item.wake_up()
			
			if item.has_node("CollisionShape2D"):
				item.get_node("CollisionShape2D").set_deferred("disabled", false)
				
			return item
			
	print_debug("Pool exhausted! Consider increasing pool size.")
	return null
