extends KinematicBody2D

const SPEED := 10

var velocity := Vector2.ZERO


func _on_TTLTimer_timeout():
	queue_free()


func init(initial_position: Vector2, direction: int) -> void:
	position = initial_position
	
	if direction == Enums.Direction.LEFT:
		velocity.x = -SPEED
	else:
		velocity.x = SPEED


func _physics_process(delta: float) -> void:
	move_and_collide(velocity)
