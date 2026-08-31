class_name MovementComponent
extends Node3D

#DECIDE QUEM VAI SE MOVER
@export var body: CharacterBody3D

@export var move_speed: float = 3.5
@export var rotation_speed: float = 8.0
@export var gravity: float = 9.8

#SEMPRE CRIAR UM NAVIGATIONAGENT QUANDO PUXAR O COMPONENTE
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

signal target_reached

var has_target: bool = false

func _ready() -> void:
	nav_agent.target_desired_distance = 0.5
	nav_agent.path_desired_distance = 0.5
	
	
func set_movement_target(target_position: Vector3) -> void:
	nav_agent.target_position = target_position
	has_target = true
	
	
func _physics_process(delta: float) -> void:
	if not body:
		return
		
		
	# Gravidade
	if not body.is_on_floor():
		body.velocity.y -= gravity * delta
		
		
		#quando a IA não tem para onde ir
	if not has_target:
		body.velocity.x = 0
		body.velocity.z = 0
		body.move_and_slide()
		return
		
		#quando ela chega ela para
	if nav_agent.is_navigation_finished():
		body.velocity.x = 0
		body.velocity.z = 0
		body.move_and_slide()
		has_target = false
		target_reached.emit()
		return
		
		#AQUI QUANDO ELA ESTÁ SE MOVENDO
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (
		next_path_position - body.global_position
	)

	direction.y = 0
	
	#fica paradinho ai meu parceiro
	if direction.length() < 0.1:
		body.velocity.x = 0
		body.velocity.z = 0
		body.move_and_slide()
		return
		
	direction = direction.normalized()
	
	body.velocity.x = direction.x * move_speed
	body.velocity.z = direction.z * move_speed
	
	
	var target_angle := atan2(direction.x, direction.z)
	
	body.rotation.y = lerp_angle(
		body.rotation.y,
		target_angle,
		rotation_speed * delta
	)
	body.move_and_slide()
