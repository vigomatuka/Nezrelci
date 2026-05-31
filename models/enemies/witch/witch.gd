extends CharacterBody3D

@export var attack_range := 15.0        # cast/detection radius
@export var attack_cooldown := 3.0
@export var max_health := 80.0

var player: CharacterBody3D = null
var gravity := 30.0
var current_health := max_health
var _can_attack := true
var _is_casting := false

@onready var _anim: AnimationPlayer = $witch/AnimationPlayer
@onready var _laser := $Laser
@onready var _hand: Node3D = $HandMarker
@onready var _charge := $HandMarker/ChargeFX
@onready var health_bar = $EnemyHealthBar

func _ready() -> void:
	add_to_group("Enemy")
	player = get_tree().get_first_node_in_group("Player")
	current_health = max_health
	health_bar.set_health(current_health, max_health)

func take_damage(amount: float) -> void:
	current_health -= amount
	health_bar.set_health(current_health, max_health)
	if current_health <= 0.0:
		queue_free()

func _physics_process(delta: float) -> void:
	if player == null:
		return

	# Gravity only — the witch never moves horizontally
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	velocity.x = 0.0
	velocity.z = 0.0
	move_and_slide()

	# Always face the player
	var to_player := player.global_position - global_position
	to_player.y = 0.0
	var distance := to_player.length()
	var direction := to_player.normalized()
	if direction.length() > 0.1:
		var target_angle = atan2(direction.x, direction.z)   # same as your assassin
		rotation.y = lerp_angle(rotation.y, target_angle, 8.0 * delta)

	# Cast when the player is inside the attack radius
	if distance <= attack_range and _can_attack and not _is_casting:
		_cast()

func _cast() -> void:
	_can_attack = false
	_is_casting = true
	_charge.start()
	_anim.play("spell_casting")
	await _anim.animation_finished
	_charge.stop()
	if is_instance_valid(player):
		var from: Vector3 = _hand.global_position
		var aim := (player.global_position - from).normalized()
		_laser.fire(from, aim)
	_is_casting = false
	await get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true
