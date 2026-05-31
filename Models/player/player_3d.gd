extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0)
var mouse_sensitivity := 0.25
var _strafe_mode := false

@export_group("Movement")
@export var move_speed := 8.0
@export var attack_move_speed := 5.0
@export var acceleration := 100.0
@export var deceleration := 200.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0
@export_group("Health")
@export var max_health := 100.0
var current_health := max_health

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -40.0
var _attack_pressed := false

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin = %main_character
@onready var _health_bar: ProgressBar = %HealthBar

func _ready() -> void:
	current_health = max_health
	_health_bar.max_value = max_health
	_health_bar.value = current_health

func take_damage(amount: float) -> void:
	current_health = max(current_health - amount, 0.0)
	_health_bar.value = current_health
	if current_health <= 0.0:
		_die()

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	_health_bar.value = current_health

func _die() -> void:
	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("left_click"):
		_attack_pressed = true
	if event.is_action_pressed("toggle_camera_mode"):
		_strafe_mode = not _strafe_mode 

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion:= (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y*delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	
	var y_velocity := velocity.y
	velocity.y = 0.0
	#Izbaceno jer je to za glatko kretanje
	#velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	var speed := move_speed
	if _skin.is_attacking:
		var t: float = _skin.get_attack_progress()

		if t > 0.5:
			# nakon pola animacije uspori
			speed = attack_move_speed
		else:
			# prije pola možeš ostaviti full speed ili lagano smanjenje
			speed = move_speed
	var target_velocity = move_direction * speed

	if move_direction.length() > 0.0:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, deceleration * delta)
		
	velocity.y = y_velocity + _gravity * delta
	move_and_slide()
	
	if _strafe_mode:
		# Camera-locked: character always faces where the camera looks
		# (turning the camera turns the player; they can strafe/back-pedal)
		var look_dir := -_camera.global_basis.z
		look_dir.y = 0.0
		look_dir = look_dir.normalized()
		if look_dir.length() > 0.0:
			var target_angle := Vector3.BACK.signed_angle_to(look_dir, Vector3.UP)
			_skin.global_rotation.y = lerp_angle(_skin.global_rotation.y, target_angle, rotation_speed * delta)
	else:
		# Free look: character faces its movement direction
		if move_direction.length() > 0.2:
			_last_movement_direction = move_direction
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.global_rotation.y, target_angle, rotation_speed * delta)
	
	# Animacije
	var ground_speed := velocity.length()
	if _attack_pressed:
		_skin.attack()
		_attack_pressed = false
	elif ground_speed > 0.1:
		_skin.run()
	else:
		_skin.idle()
