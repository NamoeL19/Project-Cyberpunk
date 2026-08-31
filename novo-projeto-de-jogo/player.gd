extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

#VARIAVEIS PARA AGACHAR E TALS
var crounchingSpeed = 2.5
var isCrouching = false


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

#HUD IMPROVISADO TIRAR DEPOIS
@onready var health_label = $PlayerHud/CanvasLayer/HealthLabel

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$HealthComponent.died.connect(on_died)
	$HealthComponent.health_changed.connect(_on_health_changed)
	
#HUD IMPROVISADO TIRAR DEPOIS
func _on_health_changed(current_health: float) -> void:
	health_label.text = "Vida: %d" % current_health
	
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
	if isCrouching:
		speed = crounchingSpeed
	elif Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
		
	#AQUI AGACHAAA
	if Input.is_action_just_pressed("crouch"):
		if isCrouching == false:
			movementStateChange("crouch")
			speed = crounchingSpeed
			print("estou furtivo igual o batman")
			
		elif isCrouching == true:
			movementStateChange("uncrouch")
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
	var target_bob = _headbob(t_bob) if direction.length() > 0.1 and is_on_floor() else Vector3.ZERO
	camera.transform.origin = camera.transform.origin.lerp(target_bob, delta * 6.0)
	
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
	
func movementStateChange(changeType):
	match changeType:
		"crouch":
			$AnimationPlayer.play("StadingToCrounch")
			isCrouching = true
			changeCollisionShapeTo("crouching")
		"uncrouch":
			$AnimationPlayer.play_backwards("StadingToCrounch")
			isCrouching = false
			changeCollisionShapeTo("standing")
			
#Change collision shapes for standing, crouch, crawl
func changeCollisionShapeTo(shape):
	match shape:
		"crouching":
			#Disabled == false is enabled!
			$CrounchCollisionShape.disabled = false
			$StandingCollisionShape.disabled = true
		"standing":
			#Disabled == false is enabled!
			$StandingCollisionShape.disabled = false
			$CrounchCollisionShape.disabled = true
			
func on_died():
	get_tree().reload_current_scene()
	
