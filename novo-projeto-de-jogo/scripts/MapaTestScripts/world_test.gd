extends Node3D

@onready var area_percepcao = $"Enemies Area/NavigationRegion3D/MeshInstance3D2/CSGSphere3D"


#AQUI É SÓ PRA LIGAR E DESLIGAR A AREA DE COLISÃO DO BONECO TESTE
var player_in_range: bool = false
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		
func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		area_percepcao.visible = not area_percepcao.visible
