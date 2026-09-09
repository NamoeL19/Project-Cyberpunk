extends State
class_name EnemyIdleTest

@export var enemy: CharacterBody3D
@export var move_speed := 3.5
@export var wander_radius := 10.0
@export var gravity := 9.8
@export var pause_time_min := 1.0
@export var pause_time_max := 2.5

var nav_agent: NavigationAgent3D
var perception: PerceptionArea
var wander_timer: float
var is_paused: bool = false
var pause_timer: float = 0.0

func enter():
	if enemy:
		nav_agent = enemy.get_node("NavigationAgent3D")
		perception = enemy.get_node("PerceptionArea")
	pick_new_wander_point()

func pick_new_wander_point():
	if not enemy or not nav_agent:
		return

	var random_offset = Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)
	if random_offset.length() < wander_radius * 0.5:
		random_offset = random_offset.normalized() * (wander_radius * 0.5)

	var target = enemy.global_position + random_offset
	nav_agent.target_position = target

	wander_timer = randf_range(4.0, 7.0)
	is_paused = false

func start_pause():
	is_paused = true
	pause_timer = randf_range(pause_time_min, pause_time_max)

func update(_delta: float):
	if perception and perception.player_visible:
		Transitioned.emit(self, "follow")
		return

	if is_paused:
		pause_timer -= _delta
		if pause_timer <= 0:
			pick_new_wander_point()
	else:
		wander_timer -= _delta
		if wander_timer <= 0:
			start_pause()

func physics_update(delta: float):
	if not enemy or not nav_agent:
		return

	if not enemy.is_on_floor():
		enemy.velocity.y -= gravity * delta

	if is_paused:
		enemy.velocity.x = lerp(enemy.velocity.x, 0.0, delta * 5.0)
		enemy.velocity.z = lerp(enemy.velocity.z, 0.0, delta * 5.0)
		enemy.move_and_slide()
		return

	if nav_agent.is_navigation_finished():
		enemy.velocity.x = lerp(enemy.velocity.x, 0.0, delta * 5.0)
		enemy.velocity.z = lerp(enemy.velocity.z, 0.0, delta * 5.0)
		enemy.move_and_slide()
		start_pause()
		return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_path_position - enemy.global_position)
	direction.y = 0
	direction = direction.normalized()

	enemy.velocity.x = lerp(enemy.velocity.x, direction.x * move_speed, delta * 4.0)
	enemy.velocity.z = lerp(enemy.velocity.z, direction.z * move_speed, delta * 4.0)

	if direction.length() > 0.1:
		var target_angle = atan2(direction.x, direction.z)
		enemy.rotation.y = lerp_angle(enemy.rotation.y, target_angle, 8.0 * delta)

	enemy.move_and_slide()
