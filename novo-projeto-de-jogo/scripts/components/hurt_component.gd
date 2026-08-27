class_name HurtBoxComponent
extends Area3D

@export var health_component: HealthComponent

func take_hit(attack: float):
	if health_component:
		health_component.damage(attack)
