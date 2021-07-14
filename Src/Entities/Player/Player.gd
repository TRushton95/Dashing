extends KinematicBody2D

const MAX_FALL_SPEED = 500
const GRAVITY_ACCELERATION = 10

var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	if velocity.y < MAX_FALL_SPEED:
		velocity.y = velocity.y + GRAVITY_ACCELERATION
	
	velocity = move_and_slide(velocity)
	
