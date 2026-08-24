extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

#BOB VARIABLES
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variable
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var gravity = 9.8

#CABEÇA
@onready var head = $head
@onready var camera = $head/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	#gravidade
	if not is_on_floor():
		velocity.y -= gravity * delta

	#AQUI É O PULO
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	


	#CORRERRRRR
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED


	#AQUI É A MOVIMENTAÇÃO BASICA DE ANDAR
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.5)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.5)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.5)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.5)
		
	#head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
