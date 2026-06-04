class_name ComboParticleSpawner
extends Node

var particle_scene := preload("res://Objects/Particle Effects/ComboParticle.tscn")

## Call this from wherever a hit is confirmed
func spawn_particles(world_pos: Vector2, combo_value: float, count: int = 3) -> void:
	for i in range(count):
		var p = particle_scene.instantiate()
		p.combo_value = combo_value / count  ## split value across particles
		p.reached_combo_ui.connect(
			get_tree().get_first_node_in_group("ComboUIFeedback").on_particle_arrived
		)
		get_tree().get_root().add_child(p)
		p.global_position = world_pos
