extends Node2D

onready var ghost_scene = preload("res://Entities/Ghost/Ghost.tscn")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG_spawn_ghost"):
		var ghost = ghost_scene.instance()
		var offset = Vector2(-50, 0) if $Player.direction == Enums.Direction.LEFT else Vector2(50, 0)
		ghost.position = $Player.position + offset
		ghost.set_direction($Player.direction)
		add_child(ghost)
