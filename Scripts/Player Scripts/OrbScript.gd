class_name ExperienceParticle
extends Area2D

var movespeed = 0
var velocity: Vector2
@export_category("Orb Stats")
@export var pointsAmount = 150
@export var experienceAmount: int = 6
@export var healAmount: float = 0.4
@export var channel_animation: AnimationPlayer
@onready var orb_sprite: Sprite2D = $OrbSprite
var homeTowardsPlayer = false
var chaseTarget: bool = false
@onready var player: Node2D
@onready var objectTarget: Node2D

## Orb Size
var orb_level: int = 1

var collEffect := preload("res://Objects/Particle Effects/CollectEffect.tscn")
func _ready():
	
	var combo_system = get_tree().get_first_node_in_group("ComboManager")
	
	## Checks if the scoring system script is attached
	
	objectTarget = get_tree().get_first_node_in_group("PlayerObject")
	print("Found: ", objectTarget)
	rotation_degrees = randf_range(0,360)
	channel_animation.play("DrawIn")
	await channel_animation.animation_finished
	chaseTarget = true
	
	self.area_entered.connect(func(area) -> void:
		if area is PlayerProjectileHitbox:
		# Since the player score script is global and autoloaded, we will increment it from here
		# along with the point orb's point amount variable
			var hitEffect = collEffect.instantiate()
			hitEffect.position = self.get_global_position()
			get_tree().get_root().call_deferred("add_child", hitEffect)
			if combo_system:
				PointSystemScript.playerScore += pointsAmount * combo_system.combo_level
			emit_effects()
			area.modify_player_health(healAmount)
			area.modify_player_experience(experienceAmount)
			queue_free()
		)


func _physics_process(delta):
	
	if GlobalBeatSync.lastBeat < GlobalBeatSync.beat:
		pass

	#OFFICIAL SCRIPT
	position += transform.x * movespeed * delta
	#if !chaseTarget:
	#	movespeed -=  300 * delta
	#if (movespeed <= 0):
	#	chaseTarget = true
	if chaseTarget and objectTarget:
		movespeed += 355 * delta
		look_at(objectTarget.global_position)
		orb_sprite.global_rotation = 0


func emit_effects():
	var collectEffect = collEffect.instantiate()
	collectEffect.position = self.get_global_position()
	get_tree().get_root().call_deferred("add_child", collEffect)
