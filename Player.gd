extends CharacterBody2D

const SPEED = 100.0
const ACCELERATION = 500.0
const FRICTION = 500.0

const ATTACK_SLIDE_SPEED = 40.0
const ATTACK_SLIDE_TIME = 0.1

const ROLL_SPEED = 130.0
const ROLL_TIME = 0.3

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var swordHitbox = $HitboxPivot/SwordHitbox

enum PlayerState { IDLE, MOVING, ATTACKING, ROLLING }
var current_state = PlayerState.IDLE

var last_direction := Vector2.DOWN
var attack_velocity := Vector2.ZERO
var attack_slide_timer := 0.0
var roll_velocity := Vector2.ZERO
var roll_timer := 0.0

func _ready():
	animation_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	match current_state:
		PlayerState.ROLLING:
			roll_timer -= delta
			if roll_timer <= 0.0:
				current_state = PlayerState.IDLE
				handle_movement(delta)
			else:
				velocity = roll_velocity
			move_and_slide()
			return

		PlayerState.ATTACKING:
			attack_slide_timer -= delta
			if attack_slide_timer <= 0.0:
				velocity = Vector2.ZERO
			else:
				velocity = attack_velocity
			move_and_slide()
			return

		_:
			handle_movement(delta)

	move_and_slide()

func handle_movement(delta: float) -> void:
	var input_direction := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
		var target_velocity = input_direction * SPEED
		velocity = velocity.move_toward(target_velocity, ACCELERATION * delta)
		last_direction = input_direction
		current_state = PlayerState.MOVING

		if abs(input_direction.x) > abs(input_direction.y):
			animation_player.play("RunRight" if input_direction.x > 0 else "RunLeft")
		else:
			animation_player.play("RunDown" if input_direction.y > 0 else "RunUp")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		current_state = PlayerState.IDLE

		if abs(last_direction.x) > abs(last_direction.y):
			animation_player.play("IdleRight" if last_direction.x > 0 else "IdleLeft")
		else:
			animation_player.play("IdleDown" if last_direction.y > 0 else "IdleUp")

func _play_attack_animation():
	current_state = PlayerState.ATTACKING

	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position

	var slide_direction := Vector2.ZERO
	if abs(to_mouse.x) > abs(to_mouse.y):
		slide_direction = Vector2.RIGHT if to_mouse.x > 0 else Vector2.LEFT
		animation_player.play("AttackingRight" if to_mouse.x > 0 else "AttackingLeft")
	else:
		slide_direction = Vector2.DOWN if to_mouse.y > 0 else Vector2.UP
		animation_player.play("AttackingDown" if to_mouse.y > 0 else "AttackingUp")

	last_direction = slide_direction
	attack_velocity = slide_direction * ATTACK_SLIDE_SPEED
	attack_slide_timer = ATTACK_SLIDE_TIME

	# Set knockback vector on sword hitbox

func _on_animation_finished(anim_name: String) -> void:
	if anim_name.begins_with("Attacking") and current_state == PlayerState.ATTACKING:
		current_state = PlayerState.IDLE
	elif anim_name.begins_with("Roll") and current_state == PlayerState.ROLLING and roll_timer <= 0.0:
		current_state = PlayerState.IDLE

func _input(event):
	if event.is_action_pressed("roll"):
		if current_state not in [PlayerState.ROLLING, PlayerState.ATTACKING]:
			_perform_roll()
	elif event.is_action_pressed("attack"):
		if current_state not in [PlayerState.ROLLING, PlayerState.ATTACKING]:
			_play_attack_animation()

func _perform_roll():
	current_state = PlayerState.ROLLING

	var input_direction := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	if input_direction == Vector2.ZERO:
		input_direction = last_direction

	roll_velocity = input_direction.normalized() * ROLL_SPEED
	roll_timer = ROLL_TIME

	if abs(input_direction.x) > abs(input_direction.y):
		animation_player.play("RollRight" if input_direction.x > 0 else "RollLeft")
	else:
		animation_player.play("RollDown" if input_direction.y > 0 else "RollUp")
