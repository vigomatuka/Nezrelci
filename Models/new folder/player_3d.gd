extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 8.0
@export var attack_move_speed := 5.0
@export var acceleration := 100.0
@export var deceleration := 200.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -40.0
var _attack_pressed := false

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: = %main_character

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("left_click"):
		_attack_pressed = true
	

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
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
	
	# Animacije
	var ground_speed := velocity.length()
	if _attack_pressed:
		_skin.attack()
		_attack_pressed = false
	elif ground_speed > 0.1:
		_skin.run()
	else:
		_skin.idle()
