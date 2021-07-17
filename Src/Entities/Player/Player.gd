extends KinematicBody2D

onready var laser_scene = preload("res://Entities/Laser/Laser.tscn")

enum State { STANDING, CROUCHING, ROLLING, FALLING, STANDING_SHOOTING, FALLING_SHOOTING }

const MAX_FALL_SPEED := 500
const GRAVITY := 20
const GLIDE_SPEED := 50
const WALK_SPEED := 200
const RUN_SPEED := 400
const JUMP_SPEED := -700
const ROLL_SPEED := 500

var speed := WALK_SPEED

var anim_state_machine

var velocity := Vector2.ZERO
var prev_direction = Enums.Direction.RIGHT
var direction = Enums.Direction.RIGHT
var gliding := false
var is_fire_on_cooldown = false

var state_stack = [ State.STANDING ]


func on_firing_animation_finished() -> void:
	is_fire_on_cooldown = false
	_pop_state()


func _on_Roll_animation_finished() -> void:
	velocity.x = 0
	$RollStunTimer.start()


func _on_RollStunTimer_timeout():
	_pop_state()


func _ready() -> void:
	anim_state_machine = $Sprite/AnimationTree.get("parameters/playback")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("sprint"):
		speed = RUN_SPEED
	elif Input.is_action_just_released("sprint"):
		speed = WALK_SPEED
		
	match state_stack[0]:
		State.STANDING:
			_process_directional_movement()
				
			if Input.is_action_just_pressed("jump"):
				_push_state(State.FALLING)
				velocity.y = JUMP_SPEED
			elif Input.is_action_just_pressed("shoot"):
				_push_state(State.STANDING_SHOOTING)
				velocity.x = 0
				_shoot()
			elif Input.is_action_pressed("crouch"):
				velocity.x = 0
				_push_state(State.CROUCHING)
			elif Input.is_action_just_pressed("roll"):
				_roll()
				
		State.FALLING:
			_process_directional_movement()
			
			if Input.is_action_just_pressed("jump"):
				gliding = true
				anim_state_machine.travel("Gliding")
			elif Input.is_action_just_released("jump"):
				gliding = false
				anim_state_machine.travel("Falling")
				
			if Input.is_action_just_pressed("shoot"):
				_push_state(State.FALLING_SHOOTING)
				_shoot()
			
			if is_on_floor():
				_pop_state()
				gliding = false
				
		State.CROUCHING:
			if !Input.is_action_pressed("crouch"):
				_pop_state()


func _physics_process(delta: float) -> void:
	if gliding:
		velocity.y = GLIDE_SPEED
	else:
		if velocity.y < MAX_FALL_SPEED:
			velocity.y = velocity.y + GRAVITY
			
	velocity = move_and_slide(velocity, Vector2.UP)


func _get_direction_modifier() -> int:
	return -1 if direction == Enums.Direction.LEFT else 1


func _shoot() -> void:
	if is_fire_on_cooldown:
		return
	
	var laser = laser_scene.instance()
	
	owner.add_child(laser)
	laser.init($LaserSpawnPoint.global_position, direction)
	
	is_fire_on_cooldown = true


func _roll() -> void:
	_push_state(State.ROLLING)
	velocity.x = ROLL_SPEED * _get_direction_modifier()


func _set_crouching_hitbox(active: bool) -> void:
	if active:
		$StandingHitbox.hide()
		$CrouchingHitbox.show()
	else:
		$StandingHitbox.show()
		$CrouchingHitbox.hide()


func _process_directional_movement() -> void:
	if Input.is_action_pressed("move_left"):
		velocity.x = -speed
		prev_direction = direction
		direction = Enums.Direction.LEFT
	elif Input.is_action_pressed("move_right"):
		velocity.x = speed
		prev_direction = direction
		direction = Enums.Direction.RIGHT
	else:
		velocity.x = 0
		
	if direction != prev_direction:
		$Sprite.transform.x = Vector2.LEFT if direction == Enums.Direction.LEFT else Vector2.RIGHT
		$LaserSpawnPoint.position = $LaserSpawnPoint.position.reflect(Vector2.UP)

func _push_state(state: int) -> void:
	state_stack.push_front(state)
	_update_animation(state)
	$StateLabel.text = State.keys()[state]


func _pop_state() -> void:
	state_stack.pop_front()
	_update_animation(state_stack[0])
	
	var state = state_stack[0]
	$StateLabel.text = State.keys()[state]


func _update_animation(state: int) -> void:
	match state:
		State.STANDING:
			anim_state_machine.travel("Idle")
		State.CROUCHING:
			anim_state_machine.travel("Crouching")
		State.ROLLING:
			anim_state_machine.travel("Rolling")
		State.FALLING:
			anim_state_machine.travel("Falling")
		State.STANDING_SHOOTING:
			anim_state_machine.travel("StandingShooting")
		State.FALLING_SHOOTING:
			anim_state_machine.travel("FallingShooting")
