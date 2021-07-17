extends KinematicBody2D

const MAX_FALL_SPEED := 500
const GRAVITY := 20
const SPEED = 100

var velocity = Vector2(SPEED, 0)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Dead":
		queue_free()


func _on_Hitbox_body_entered(body: PhysicsBody2D) -> void:
	if body.is_in_group("player_attacks"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		$CollisionShape2D.set_deferred("disabled", true)
		set_physics_process(false)
		$Sprite/AnimationPlayer.play("Dead")
		
	if body.is_in_group("player"):
		var side_collided = Enums.Direction.RIGHT if body.position.x < position.x else Enums.Direction.LEFT
		body.hit(side_collided)


func set_direction(direction: int) -> void:
	if direction == Enums.Direction.LEFT:
		velocity.x = -SPEED
		$Sprite.transform.x = Vector2.LEFT
		$GroundDetector.position.x = -abs($GroundDetector.position.x)
	else:
		velocity.x = SPEED
		$Sprite.transform.x = Vector2.RIGHT
		$GroundDetector.position.x = abs($GroundDetector.position.x)


func _physics_process(delta: float) -> void:
	if !$GroundDetector.is_colliding():
		velocity.x = -velocity.x
		transform.x = -transform.x
	
	
	if velocity.y < MAX_FALL_SPEED:
		velocity.y = velocity.y + GRAVITY
	
	velocity = move_and_slide(velocity, Vector2.UP)
