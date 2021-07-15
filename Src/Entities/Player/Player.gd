extends KinematicBody2D

onready var laser_scene = preload("res://Entities/Laser/Laser.tscn")

enum State { STANDING, FALLING, FIRING }

const MAX_FALL_SPEED := 500
const GRAVITY_ACCELERATION := 20
const GLIDE_SPEED := 50
const WALK_SPEED := 200
const RUN_SPEED := 400
const JUMP_SPEED := -700

var move_speed := WALK_SPEED

var velocity := Vector2.ZERO
var direction = Enums.Direction.RIGHT
var gliding := false

var state_stack = [ State.STANDING ]


func _on_FiringAnimTimer_timeout() -> void:
	_pop_state()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("sprint"):
		move_speed = RUN_SPEED
	elif Input.is_action_just_released("sprint"):
		move_speed = WALK_SPEED
		
	match state_stack[0]:
		State.STANDING:
			_process_directional_movement()
				
			if Input.is_action_just_pressed("jump"):
				_push_state(State.FALLING)
				velocity.y = JUMP_SPEED
				
			elif Input.is_action_just_pressed("shoot"):
				_push_state(State.FIRING)
				velocity.x = 0
				$FiringAnimTimer.start()
				_shoot()
				
		State.FALLING:
			_process_directional_movement()
			
			if Input.is_action_just_pressed("jump"):
				gliding = true
			elif Input.is_action_just_released("jump"):
				gliding = false
			
			if is_on_floor():
				_pop_state()
				gliding = false


func _physics_process(delta: float) -> void:
	if gliding:
		velocity.y = GLIDE_SPEED
	else:
		if velocity.y < MAX_FALL_SPEED:
			velocity.y = velocity.y + GRAVITY_ACCELERATION
			
	velocity = move_and_slide(velocity, Vector2.UP)


func _get_direction_modifier() -> int:
	return -1 if direction == Enums.Direction.LEFT else 1


func _shoot() -> void:
	var laser = laser_scene.instance()
	var delta_x = $Sprite.texture.get_width() / 2
	
	var x = position.x + (delta_x * _get_direction_modifier())
	var y = position.y
	
	owner.add_child(laser)
	laser.init(Vector2(x, y), direction)


func _process_directional_movement() -> void:
	if Input.is_action_pressed("move_left"):
		velocity.x = -move_speed
		direction = Enums.Direction.LEFT
	elif Input.is_action_pressed("move_right"):
		velocity.x = move_speed
		direction = Enums.Direction.RIGHT
	else:
		velocity.x = 0


func _push_state(state: int) -> void:
	state_stack.push_front(state)
	$StateLabel.text = State.keys()[state]


func _pop_state() -> void:
	state_stack.pop_front()
	
	var state = state_stack[0]
	$StateLabel.text = State.keys()[state]
