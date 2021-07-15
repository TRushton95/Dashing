extends KinematicBody2D

onready var laser_scene = preload("res://Entities/Laser/Laser.tscn")

export var MAX_FALL_SPEED := 500
const GRAVITY_ACCELERATION := 20
const WALK_SPEED := 200
const RUN_SPEED := 400
const JUMP_SPEED := -700

var move_speed := WALK_SPEED

var velocity := Vector2.ZERO
var direction = Enums.Direction.RIGHT


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("sprint"):
		move_speed = RUN_SPEED
	elif Input.is_action_just_released("sprint"):
		move_speed = WALK_SPEED
	
	if Input.is_action_pressed("move_left"):
		velocity.x = -move_speed
		direction = Enums.Direction.LEFT
	elif Input.is_action_pressed("move_right"):
		velocity.x = move_speed
		direction = Enums.Direction.RIGHT
	else:
		velocity.x = 0
		
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED
		
	if Input.is_action_just_pressed("shoot"):
		_shoot()


func _physics_process(delta: float) -> void:
	if velocity.y < MAX_FALL_SPEED:
		velocity.y = velocity.y + GRAVITY_ACCELERATION
	
	velocity = move_and_slide(velocity)


func _get_direction_modifier() -> int:
	return -1 if direction == Enums.Direction.LEFT else 1


func _shoot() -> void:
	var laser = laser_scene.instance()
	var delta_x = $Sprite.texture.get_width() / 2
	
	var x = position.x + (delta_x * _get_direction_modifier())
	var y = position.y
	
	owner.add_child(laser)
	laser.init(Vector2(x, y), direction)
