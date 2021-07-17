extends KinematicBody2D

const MAX_FALL_SPEED := 500
const GRAVITY_ACCELERATION := 20
const MOVEMENT_SPEED = 100

var velocity = Vector2(MOVEMENT_SPEED, 0)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Dead":
		queue_free()


func _on_Hitbox_body_entered(body: PhysicsBody2D) -> void:
	if body.is_in_group("player_projectiles"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		$Hurtbox.set_deferred("disabled", true)
		set_physics_process(false)
		$Sprite/AnimationPlayer.play("Dead")


func set_direction(direction: int) -> void:
	if direction == Enums.Direction.LEFT:
		velocity.x = -MOVEMENT_SPEED
		$Sprite.transform.x = Vector2.LEFT
		$GroundDetector.position.x = -abs($GroundDetector.position.x)
	else:
		velocity.x = MOVEMENT_SPEED
		$Sprite.transform.x = Vector2.RIGHT
		$GroundDetector.position.x = abs($GroundDetector.position.x)


func _physics_process(delta: float) -> void:
	if !$GroundDetector.is_colliding():
		velocity.x = -velocity.x
		transform.x = -transform.x
	
	
	if velocity.y < MAX_FALL_SPEED:
		velocity.y = velocity.y + GRAVITY_ACCELERATION
	
	velocity = move_and_slide(velocity, Vector2.UP)
