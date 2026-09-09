extends Area3D
class_name PerceptionArea

signal player_detected
signal player_lost

@export var eye_height := 1.6
@export var sight_check_interval := 0.2

var player: CharacterBody3D
var player_in_range: bool = false
var player_visible: bool = false
var sight_check_timer: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body
		player_in_range = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		player_visible = false
		player = null

func _process(delta: float) -> void:
	if not player_in_range or not player:
		return

	sight_check_timer -= delta
	if sight_check_timer <= 0:
		sight_check_timer = sight_check_interval
		_check_line_of_sight()

func _check_line_of_sight() -> void:
	var space_state = get_world_3d().direct_space_state
	var from = global_position + Vector3(0, eye_height, 0)
	var to = player.global_position + Vector3(0, eye_height, 0)

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_parent()]

	var result = space_state.intersect_ray(query)
	var can_see: bool = result.is_empty() or result.collider == player

	if can_see and not player_visible:
		player_visible = true
		player_detected.emit()
	elif not can_see and player_visible:
		player_visible = false
		player_lost.emit()
