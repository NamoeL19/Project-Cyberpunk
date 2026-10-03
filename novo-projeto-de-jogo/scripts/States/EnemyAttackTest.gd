extends State
class_name EnemyAttackState

@export var enemy: CharacterBody3D
@export var gravity := 9.8
@export var attack_range_percent := 0.7
@export var attack_range_buffer := 2.0
@export var lose_sight_time := 1.5
@export var rotation_speed := 10.0
@export var reaction_time := 0.5  
@export var attack_interval := 1.2

var player: CharacterBody3D
var perception: PerceptionArea
var weapon_controller: WeaponController
var lost_sight_timer: float
var reaction_timer: float
var attack_cooldown_timer: float
var was_visible_last_frame: bool

func enter():
	player = get_tree().get_first_node_in_group("player")
	if enemy:
		perception = enemy.get_node("PerceptionArea")
		weapon_controller = enemy.get_node("Components/WeaponController")
	lost_sight_timer = lose_sight_time
	reaction_timer = reaction_time
	attack_cooldown_timer = 0.0
	was_visible_last_frame = false

func get_attack_range() -> float:
	var weapon_reach := 10.0
	if weapon_controller and weapon_controller.current_weapon:
		weapon_reach = weapon_controller.current_weapon.weapon_range * attack_range_percent

	var perception_radius := 10.0
	if perception:
		perception_radius = perception.get_radius()

	return min(weapon_reach, perception_radius)

func update(_delta: float):
	if not player or not perception:
		return

	if perception.player_visible:
		lost_sight_timer = lose_sight_time

		# acabou de reaparecer depois de ter se escondido: reseta o tempo de
		# "mira", dando outra chance de reação em vez de atirar instantaneamente
		if not was_visible_last_frame:
			reaction_timer = reaction_time
		was_visible_last_frame = true

		var distance = enemy.global_position.distance_to(player.global_position)
		if distance > get_attack_range() + attack_range_buffer:
			Transitioned.emit(self, "follow")
			return

		if reaction_timer > 0:
			reaction_timer -= _delta
			return  # ainda "mirando", ainda não atira

		attack_cooldown_timer -= _delta
		if attack_cooldown_timer <= 0:
			_try_attack()
			attack_cooldown_timer = attack_interval
	else:
		was_visible_last_frame = false
		lost_sight_timer -= _delta
		if lost_sight_timer <= 0:
			Transitioned.emit(self, "idle")

func _try_attack() -> void:
	if not weapon_controller or not is_instance_valid(weapon_controller) or not weapon_controller.current_weapon:
		return

	match weapon_controller.current_weapon.weapon_type:
		Weapon.WeaponType.RANGED:
			weapon_controller.fire()
		Weapon.WeaponType.MELEE:
			pass

func physics_update(delta: float):
	if not enemy or not player:
		return

	if not enemy.is_on_floor():
		enemy.velocity.y -= gravity * delta

	enemy.velocity.x = lerp(enemy.velocity.x, 0.0, delta * 5.0)
	enemy.velocity.z = lerp(enemy.velocity.z, 0.0, delta * 5.0)

	var direction = (player.global_position - enemy.global_position)
	direction.y = 0
	if direction.length() > 0.1:
		direction = direction.normalized()
		var target_angle = atan2(direction.x, direction.z)
		enemy.rotation.y = lerp_angle(enemy.rotation.y, target_angle, rotation_speed * delta)

	enemy.move_and_slide()
