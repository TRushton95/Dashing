class_name Player
extends KinematicBody2D

onready var laser_scene = preload("res://Entities/Laser/Laser.tscn")

enum State { STANDING, CROUCHING, ROLLING, FALLING, STANDING_SHOOTING, FALLING_SHOOTING, DAMAGED }

const MAX_FALL_SPEED := 500
const GRAVITY := 20
const GLIDE_SPEED := 50
const WALK_SPEED := 200
const RUN_SPEED := 400
const JUMP_SPEED := -700
const ROLL_SPEED := 500

onready var anim_player = $Sprite/AnimationPlayer

var speed := WALK_SPEED
var velocity := Vector2.ZERO
var prev_direction = Enums.Direction.RIGHT
var direction = Enums.Direction.RIGHT
var gliding := false
var is_fire_on_cooldown = false
var state_stack = [ State.STANDING ]


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"StandingShooting", "FallingShooting":
			_pop_state()
		"Rolling":
			velocity.x = 0
			$RollStunTimer.start()


func _on_FiringCooldownTimer_timeout() -> void:
	is_fire_on_cooldown = false


func _on_RollStunTimer_timeout() -> void:
	_pop_state()


func _on_InvulnTimer_timeout() -> void:
	set_collision_layer_bit(0, true)


func hit(side_collided: int) -> void:
	_push_state(State.DAMAGED)
	
	gliding = false
	var recoil_direction = -1 * _get_direction_vector(side_collided).x
	velocity.x = 200 * recoil_direction
	velocity.y = -300
	
	$Sprite.modulate.a = 0.2
	set_collision_layer_bit(0, false)


func get_bounds() -> Rect2:
	return get_node("Sprite").get_rect()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("sprint"):
		speed = RUN_SPEED
	elif Input.is_action_just_released("sprint"):
		speed = WALK_SPEED
		
	match state_stack[0]:
		State.STANDING:
			_handle_directional_input()
			
			if !is_on_floor():
				_push_state(State.FALLING)
				
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_SPEED
			elif Input.is_action_just_pressed("shoot"):
				if !is_fire_on_cooldown:
					_push_state(State.STANDING_SHOOTING)
					velocity.x = 0
					_shoot()
			elif Input.is_action_pressed("crouch"):
				velocity.x = 0
				_push_state(State.CROUCHING)
			elif Input.is_action_just_pressed("roll"):
				_roll()
				
		State.FALLING:
			_handle_directional_input()
			
			if Input.is_action_just_pressed("jump"):
				gliding = true
				anim_player.play("Gliding")
			elif Input.is_action_just_released("jump"):
				gliding = false
				anim_player.play("Falling")
				
			if Input.is_action_just_pressed("shoot"):
				if !is_fire_on_cooldown:
					_push_state(State.FALLING_SHOOTING)
					_shoot()
			
			if is_on_floor():
				_pop_state()
				gliding = false
				
		State.CROUCHING:
			if !Input.is_action_pressed("crouch"):
				_pop_state()
				
		State.FALLING_SHOOTING:
			if is_on_floor():
				_pop_state()
				
		State.DAMAGED:
			if is_on_floor():
				_pop_state()
				$InvulnTimer.start()
				anim_player.play("Invulnerable")


func _physics_process(delta: float) -> void:
	if gliding:
		velocity.y = GLIDE_SPEED
	else:
		if velocity.y < MAX_FALL_SPEED:
			velocity.y = velocity.y + GRAVITY
			
	velocity = move_and_slide(velocity, Vector2.UP)


func _shoot() -> void:
	var laser = laser_scene.instance()
	owner.add_child(laser)
	laser.init($LaserSpawnPoint.global_position, direction)
	is_fire_on_cooldown = true
	$FiringCooldownTimer.start()


func _roll() -> void:
	_push_state(State.ROLLING)
	velocity.x = ROLL_SPEED * _get_direction_vector(direction).x


func _set_crouching_hitbox(active: bool) -> void:
	if active:
		$StandingHitbox.hide()
		$CrouchingHitbox.show()
	else:
		$StandingHitbox.show()
		$CrouchingHitbox.hide()


func _handle_directional_input() -> void:
	if Input.is_action_pressed("move_left"):
		velocity.x = -speed
		_update_direction(Enums.Direction.LEFT)
	elif Input.is_action_pressed("move_right"):
		velocity.x = speed
		_update_direction(Enums.Direction.RIGHT)
	else:
		velocity.x = 0


func _update_direction(new_direction: int) -> void:
	prev_direction = direction
	direction = new_direction
	
	if direction != prev_direction:
		$Sprite.transform.x = _get_direction_vector(direction)
		$LaserSpawnPoint.position = $LaserSpawnPoint.position.reflect(Vector2.UP)


func _get_direction_vector(direction: int) -> Vector2:
	return Vector2.LEFT if direction == Enums.Direction.LEFT else Vector2.RIGHT


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
			anim_player.play("Idle")
		State.CROUCHING:
			anim_player.play("Crouching")
		State.ROLLING:
			anim_player.play("Rolling")
		State.FALLING:
			anim_player.play("Falling")
		State.STANDING_SHOOTING:
			anim_player.play("StandingShooting")
		State.FALLING_SHOOTING:
			anim_player.play("FallingShooting")
		State.DAMAGED:
			anim_player.play("Damaged")
