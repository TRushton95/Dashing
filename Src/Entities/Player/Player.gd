extends KinematicBody2D

const MAX_FALL_SPEED = 500
const GRAVITY_ACCELERATION = 20
const WALK_SPEED = 200
const JUMP_SPEED = -700

var velocity := Vector2.ZERO


func _process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		velocity.x = -WALK_SPEED
	elif Input.is_action_pressed("move_right"):
		velocity.x = WALK_SPEED
	else:
		velocity.x = 0
		
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED


func _physics_process(delta: float) -> void:
	if velocity.y < MAX_FALL_SPEED:
		velocity.y = velocity.y + GRAVITY_ACCELERATION
	
	velocity = move_and_slide(velocity)
	
