extends KinematicBody2D


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Dead":
		queue_free()


func _on_Hitbox_body_entered(body: PhysicsBody2D) -> void:
	if body.is_in_group("player_projectiles"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		$Hurtbox.set_deferred("disabled", true)
		$Sprite/AnimationPlayer.play("Dead")
