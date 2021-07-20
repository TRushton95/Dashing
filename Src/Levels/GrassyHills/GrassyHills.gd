extends Node2D

onready var player_scene = preload("res://Entities/Player/Player.tscn")
onready var ghost_scene = preload("res://Entities/Ghost/Ghost.tscn")


func _on_DeathZones_body_entered(body: Node) -> void:
	if body is Player:
		body.position = $SpawnPosition.position


func _ready() -> void:
	var player = player_scene.instance()
	player.position = $SpawnPosition.position
	add_child(player)
	player.owner = self


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG_spawn_ghost"):
		var ghost = ghost_scene.instance()
		var offset = Vector2(-50, 0) if $Player.direction == Enums.Direction.LEFT else Vector2(50, 0)
		ghost.position = $Player.position + offset
		ghost.set_direction($Player.direction)
		add_child(ghost)
