class_name WeaponController extends Node

@export var current_weapon: Weapon
@export var weapon_model_parent: Node3D
@export var camera: Camera3D
@export var shooter: Node3D

var current_weapon_model: Node3D
var current_ammo: int
var can_fire: bool = true

func _ready() -> void:
	if current_weapon:
		spawn_weapon_model()
		current_ammo = current_weapon.max_ammo

func spawn_weapon_model():
	if current_weapon_model:
		current_weapon_model.queue_free()

	if current_weapon.weapon_model:
		current_weapon_model = current_weapon.weapon_model.instantiate()
		weapon_model_parent.add_child(current_weapon_model)
		current_weapon_model.position = current_weapon.weapon_position

func fire() -> void:
	if not can_fire or not current_weapon:
		return

	if current_ammo <= 0:
		print("Sem munição!")
		return

	can_fire = false
	current_ammo -= 1
	print("Atirou! Munição restante: ", current_ammo)

	_perform_raycast()

	# cooldown até poder atirar de novo
	await get_tree().create_timer(current_weapon.fire_rate).timeout
	can_fire = true

func _perform_raycast() -> void:
	var space_state = camera.get_world_3d().direct_space_state
	var from = camera.global_position
	var to = from + (-camera.global_transform.basis.z * current_weapon.range)

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [shooter]
	
	#PRA COLIDIR COM AREAS
	query.collide_with_areas = true
	
	# ainda detecta paredes normalmente
	query.collide_with_bodies = true 

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		print("Tiro não acertou nada")
		return

	var collider = result.collider
	print("Acertou: ", collider.name)

	if collider is HurtBoxComponent:
		collider.take_hit(current_weapon.damage)
