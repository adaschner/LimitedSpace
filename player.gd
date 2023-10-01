extends CharacterBody2D


@export var movement_data : PlayerMovementData

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var blood_particles = load("res://blood_particles.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position
@onready var death_timer = $DeathTimer
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

var jump_count = 0
var can_move = true

func _ready():
	Events.dot_collected.connect(dot_collected)

func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	var input_axis = Input.get_axis("ui_left", "ui_right")
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta
		
func handle_jump():
	if not can_move: return
	if jump_count > 0 or (jump_count > 0 and coyote_jump_timer.time_left > 0.0):
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = movement_data.jump_velocity
			jump_count -= 1
	if not is_on_floor():
		if Input.is_action_just_released("ui_accept") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2

func handle_acceleration(input_axis, delta):
	if not is_on_floor() or not can_move: return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if is_on_floor() or not can_move: return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func apply_friction(input_axis, delta):
	if not can_move: return
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if not can_move: return
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func update_animations(input_axis):
	if not can_move: return
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")

func dot_collected():
	audio_stream_player_2d.play()
	jump_count += 1

func die():
	print("died")
	can_move = false
	var blood = blood_particles.instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = self.global_position
	animated_sprite_2d.rotate(-90.0)
	animated_sprite_2d.play("death")
	if Global.lives > 0:
		death_timer.start()
	else:
		Events.game_over.emit()

func _on_death_timer_timeout():
	queue_free()
	get_tree().reload_current_scene()
	get_tree().paused = false


func _on_hazard_detector_area_entered(area):
	print(Global.lives)
	print_stack()
	Global.lives -= 1
	get_tree().paused = true
	die()
	print(Global.lives)
