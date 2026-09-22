class_name WeaponController extends Node

signal ammo_changed(current_ammo: int, max_ammo: int, weapon_name: String)
signal reload_started(reload_time: float)

@export var current_weapon: Weapon
@export var weapon_model_parent: Node3D
@export var muzzle_raycast: RayCast3D
@export var shooter: Node3D
@export var infinite_ammo: bool = false

var current_weapon_model: Node3D
var current_ammo: int
var can_fire: bool = true
var is_reloading: bool = false

func _ready() -> void:
	if current_weapon:
		spawn_weapon_model()
		current_ammo = current_weapon.max_ammo
		_emit_ammo_changed()

	if muzzle_raycast and shooter:
		muzzle_raycast.add_exception(shooter)

func spawn_weapon_model():
	if current_weapon_model:
		current_weapon_model.queue_free()

	if current_weapon.weapon_model:
		current_weapon_model = current_weapon.weapon_model.instantiate()
		weapon_model_parent.add_child(current_weapon_model)
		current_weapon_model.position = current_weapon.weapon_position

func fire() -> void:
	if not can_fire or not current_weapon or is_reloading:
		return

	if current_ammo <= 0 and not infinite_ammo:
		print("Sem munição! Aperte R pra recarregar")
		return

	can_fire = false
	if not infinite_ammo:
		current_ammo -= 1
		_emit_ammo_changed()
	print("Atirou! Munição restante: ", current_ammo if not infinite_ammo else "∞")

	_check_hit()

	await get_tree().create_timer(current_weapon.fire_rate).timeout
	can_fire = true

func reload() -> void:
	if not current_weapon or is_reloading or infinite_ammo:
		return

	if current_ammo >= current_weapon.max_ammo:
		print("Munição já está cheia")
		return

	is_reloading = true
	can_fire = false
	print("Recarregando...")
	reload_started.emit(current_weapon.reload_time)

	await get_tree().create_timer(current_weapon.reload_time).timeout

	current_ammo = current_weapon.max_ammo
	is_reloading = false
	can_fire = true
	_emit_ammo_changed()
	print("Recarregou! Munição: ", current_ammo, " / ", current_weapon.max_ammo)

func _emit_ammo_changed() -> void:
	if current_weapon:
		ammo_changed.emit(current_ammo, current_weapon.max_ammo, current_weapon.weapon_name)

func _check_hit() -> void:
	if not muzzle_raycast:
		return

	muzzle_raycast.force_raycast_update()

	if not muzzle_raycast.is_colliding():
		print("Tiro não acertou nada")
		return

	var collider = muzzle_raycast.get_collider()
	print("Acertou: ", collider.name)

	if collider is HurtBoxComponent:
		collider.take_hit(current_weapon.damage)
