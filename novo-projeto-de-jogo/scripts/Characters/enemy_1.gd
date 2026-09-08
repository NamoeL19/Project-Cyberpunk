extends CharacterBody3D
class_name EnemyTest

@onready var health_label = $HPBar

func _ready() -> void:
	$HealthComponent.died.connect(on_died)
	$HealthComponent.health_changed.connect(_on_health_changed)
	
#HUD IMPROVISADO TIRAR DEPOIS
func _on_health_changed(current_health: float) -> void:
	health_label.text = "HP: %d" % current_health

func on_died():
	queue_free()
