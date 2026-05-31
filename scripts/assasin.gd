extends CharacterBody3D

@export var move_speed := 4.0
@export var attack_range := 1.5

var player: CharacterBody3D = null
var gravity := 30.0
var is_attacking := false

@onready var skin: Node3D = $assassin

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	print(get_children())

func _physics_process(delta: float) -> void:
	if player == null:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var direction = player.global_position - global_position
	direction.y = 0.0
	var distance = direction.length()
	direction = direction.normalized()

	if is_attacking:
		# Čekaj kraj attack animacije
		if skin.is_attack_finished():
			is_attacking = false
		# Ne miči se za vrijeme napada
		velocity.x = 0.0
		velocity.z = 0.0
	elif distance <= attack_range:
		# Napadni
		is_attacking = true
		skin.play_attack()
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		# Trči prema igraču
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		skin.play_run()

	# Rotacija prema igraču
	if direction.length() > 0.1 and not is_attacking:
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 8.0 * delta)

	move_and_slide()
