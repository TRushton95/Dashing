extends Node2D

onready var ghost_scene = preload("res://Entities/Ghost/Ghost.tscn")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG_spawn_ghost"):
		var ghost = ghost_scene.instance()
		ghost.position = $Player.position + Vector2(50, 0)
		add_child(ghost)
