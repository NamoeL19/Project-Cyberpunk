extends State
class_name EnemyFollowTest

@export var enemy: CharacterBody3D
@export var move_speed := 40

var player: CharacterBody3D

func enter():
	player = get_tree().get_first_node_in_group("player")


func physics_update(_delta: float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 25:
		enemy.velocity = direction.normalized() * move_speed
		
		
