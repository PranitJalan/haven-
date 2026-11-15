extends CharacterBody2D


@export var gravity := 960
@export var acceleration := 200
@export var friction := 30000000
@export var jump_strength := 200
@export var max_speed := 600
@export var range := 200
@export var distance := 750
@export var health := 5

var direction := 0
var jump := false

func _physics_process(delta: float) -> void:
	get_input()
	set_stuff(delta)
	move_and_slide()

func get_input():
	var player = get_tree().get_first_node_in_group("player")
	if abs(player.global_position.x - global_position.x) < range:
		if player.global_position.x < global_position.x:
			if abs(player.global_position.x - global_position.x) < distance:
				direction = 1
			elif abs(player.global_position.x - global_position.x) > distance:
				direction = -1
			else:
				direction = 0
		elif player.global_position.x > global_position.x:
			if abs(player.global_position.x - global_position.x) < distance:
				direction = -1
			elif abs(player.global_position.x - global_position.x) > distance:
				direction = 1
			else:
				direction = 0
			
		else:
			direction  = 0
		
	

func set_stuff(delta):
	if direction:
		velocity.x = move_toward(velocity.x, max_speed*direction, acceleration*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
	
	if not is_on_floor():
		velocity.y += gravity
	else:
		if jump:
			velocity.y -= jump_strength
			
func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy health: ", health)
	
	if health <= 0:
		queue_free()
