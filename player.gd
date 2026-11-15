extends CharacterBody2D

@export var gravity := 960
@export var acceleration := 200
@export var friction := 200
@export var jump_strength := 200
@export var max_speed := 600

var direction := 1
var jump := false

func _physics_process(delta: float) -> void:
	get_input()
	set_stuff(delta)
	move_and_slide()

func get_input():
	direction = Input.get_axis("Left", "right")
	if Input.is_action_just_pressed("Jump"):
		jump = true


func set_stuff(delta):
	if direction:
		velocity.x = move_toward(velocity.x, max_speed*direction, acceleration*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction*delta)
	
	if not is_on_floor():
		velocity.y += gravity
	else:
		if jump:
			velocity.y -= jump_strength
