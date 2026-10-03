extends State
class_name EnemyFollowTest

@export var enemy: CharacterBody3D
@export var move_speed := 4.5
@export var gravity := 9.8
@export var lose_sight_time := 1.5
@export var attack_range_percent := 0.7

var player: CharacterBody3D
var nav_agent: NavigationAgent3D
var perception: PerceptionArea
var weapon_controller: WeaponController
var lost_sight_timer: float

func enter():
	if enemy:
		nav_agent = enemy.get_node("NavigationAgent3D")
		perception = enemy.get_node("PerceptionArea")
		weapon_controller = enemy.get_node("Components/WeaponController")
	player = get_tree().get_first_node_in_group("player")
	lost_sight_timer = lose_sight_time

func get_attack_range() -> float:
	var weapon_reach := 10.0
	if weapon_controller and weapon_controller.current_weapon:
		weapon_reach = weapon_controller.current_weapon.weapon_range * attack_range_percent

	var perception_radius := 10.0
	if perception:
		perception_radius = perception.get_radius()

	print("weapon_reach: ", weapon_reach, " | perception_radius: ", perception_radius)

	return min(weapon_reach, perception_radius)

func update(_delta: float):
	if perception and perception.player_visible:
		lost_sight_timer = lose_sight_time
		if nav_agent and player:
			nav_agent.target_position = player.global_position

		var distance = enemy.global_position.distance_to(player.global_position)
		var attack_range = get_attack_range()
		print("distância: ", distance, " | attack_range: ", attack_range)
		if distance <= attack_range:
			Transitioned.emit(self, "attack")
			return
	else:
		lost_sight_timer -= _delta
		if lost_sight_timer <= 0:
			Transitioned.emit(self, "idle")

func physics_update(delta: float):
	if not enemy or not nav_agent or not player:
		return

	if not enemy.is_on_floor():
		enemy.velocity.y -= gravity * delta

	if nav_agent.is_navigation_finished():
		enemy.velocity.x = lerp(enemy.velocity.x, 0.0, delta * 5.0)
		enemy.velocity.z = lerp(enemy.velocity.z, 0.0, delta * 5.0)
		enemy.move_and_slide()
		return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_path_position - enemy.global_position)
	direction.y = 0
	direction = direction.normalized()

	enemy.velocity.x = lerp(enemy.velocity.x, direction.x * move_speed, delta * 4.0)
	enemy.velocity.z = lerp(enemy.velocity.z, direction.z * move_speed, delta * 4.0)

	if direction.length() > 0.1:
		var target_angle = atan2(direction.x, direction.z)
		enemy.rotation.y = lerp_angle(enemy.rotation.y, target_angle, 10.0 * delta)

	enemy.move_and_slide()
