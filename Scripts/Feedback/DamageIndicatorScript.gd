extends Node

enum DamageSide {
	Player,
	Enemy
}

@export var indicator_side = DamageSide.Player
@onready var damage_text: Label = $DamageText

@export var damage_value: int = 50
@export var damage_crit: bool
@export var indicator_lifetime: float = 25
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	indicator_lifetime -= 60 * delta
	pass
