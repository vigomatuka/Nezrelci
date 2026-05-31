## Player3D.gd
## Prikvači na CharacterBody3D node (tvoj igrač).
## Dodaj igrača u grupu "player" (Node > Groups u Inspectoru).
##
## VAŽNO: Ovaj skript pretpostavlja da imaš:
##   - Camera3D kao dijete (ili SpringArm3D > Camera3D za third person)
##   - CollisionShape3D kao dijete

extends CharacterBody3D

# ─── Konstante kretanja ────────────────────────────────────────────────────────
const SPEED        := 5.0
const JUMP_FORCE   := 6.0
const GRAVITY      := 20.0
const MOUSE_SENS   := 0.002   # osjetljivost miša za kameru
const LIMBO_SPEED  := 0.4     # faktor usporavanja u limbu (40% normalne brzine)

# ─── Node reference ────────────────────────────────────────────────────────────
## Postavi u Inspectoru — povuci SpringArm3D ili Camera3D node ovdje
@export var camera_pivot: Node3D   # SpringArm3D ili Node3D koji rotira kameru

# ─── Stanje ────────────────────────────────────────────────────────────────────
var in_limbo: bool = false
var _camera_yaw: float = 0.0
var _camera_pitch: float = 0.0

# ─── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	LimboManager.limbo_progress.connect(_on_limbo_progress)
	LimboManager.limbo_ended.connect(_on_limbo_ended)


func _input(event: InputEvent) -> void:
	# Rotacija kamere mišem
	if event is InputEventMouseMotion and not in_limbo:
		_camera_yaw -= event.relative.x * MOUSE_SENS
		_camera_pitch -= event.relative.y * MOUSE_SENS
		_camera_pitch = clamp(_camera_pitch, -1.2, 0.8)

		rotation.y = _camera_yaw
		if camera_pivot:
			camera_pivot.rotation.x = _camera_pitch

	# Otpusti miš s Escape
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	# Gravitacija
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Horizontalno kretanje (relativno prema smjeru gledanja)
	var input_dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	var current_speed := SPEED * (LIMBO_SPEED if in_limbo else 1.0)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# Skok (u limbu nije moguće skočiti)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not in_limbo:
		velocity.y = JUMP_FORCE

	move_and_slide()


# ─── Limbo API ─────────────────────────────────────────────────────────────────

func enter_limbo() -> void:
	in_limbo = true
	# vizualni efekt je u LimboOverlay3D (ljubičasti fade preko ekrana)


func exit_limbo() -> void:
	in_limbo = false
	velocity = Vector3.ZERO


# ─── Signali od LimboManagera ─────────────────────────────────────────────────

func _on_limbo_progress(_t: float) -> void:
	pass  # vizualni efekt je u LimboOverlay3D


func _on_limbo_ended() -> void:
	pass  # vizualni efekt je u LimboOverlay3D
