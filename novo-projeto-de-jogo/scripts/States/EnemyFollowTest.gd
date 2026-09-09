extends State
class_name EnemyFollowTest

@export var enemy: CharacterBody3D
@export var move_speed := 4.5
@export var gravity := 9.8
@export var lose_sight_time := 1.5

var player: CharacterBody3D
var nav_agent: NavigationAgent3D
var perception: PerceptionArea
var lost_sight_timer: float

func enter():
	if enemy:
		nav_agent = enemy.get_node("NavigationAgent3D")
		perception = enemy.get_node("PerceptionArea")
	player = get_tree().get_first_node_in_group("player")
	lost_sight_timer = lose_sight_time

func update(_delta: float):
	if perception and perception.player_visible:
		lost_sight_timer = lose_sight_time
		if nav_agent and player:
			nav_agent.target_position = player.global_position
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
