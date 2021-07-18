extends StaticBody2D


func _on_PassThroughDetector_body_entered(body: Node) -> void:
	if body is Player:
		var player_bottom = body.position.y + body.get_bounds().size.y
		if player_bottom > position.y:
			add_collision_exception_with(body)


func _on_PassThroughDetector_body_exited(body: Node) -> void:
	if body is Player:
		remove_collision_exception_with(body)
