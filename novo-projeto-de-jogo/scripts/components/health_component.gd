class_name HealthComponent
extends Node

#SINAIS
signal died
signal health_changed(new_amount)

@export var max_health := 10
var current_health: float

func _ready():
	current_health = max_health
	health_changed.emit(current_health)
	
func damage(attack: float):
	current_health -= attack
	health_changed.emit(current_health)
	
	if current_health <= 0:
		died.emit()
