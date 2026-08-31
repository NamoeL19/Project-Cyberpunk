extends CharacterBody3D

@onready var movement: MovementComponent = $MovementComponent

func _ready() -> void:
	await get_tree().physics_frame
	movement.set_movement_target(Vector3(-35, 0, 5))
