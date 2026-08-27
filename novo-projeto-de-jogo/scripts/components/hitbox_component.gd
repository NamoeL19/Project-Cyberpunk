class_name HitBoxComponent
extends Area3D

@export var attack_damage := 10.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area3D) -> void:
	if area is HurtBoxComponent:
		area.take_hit(attack_damage)
