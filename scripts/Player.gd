## Player.gd
## CharacterBody2D s podrškom za limbo stanje.
## Dodaj igrača u grupu "player" (Node > Groups).

extends CharacterBody2D

# ─── Konstante ─────────────────────────────────────────────────────────────────
const SPEED        := 200.0
const GRAVITY      := 900.0
const JUMP_FORCE   := -420.0
const LIMBO_SPEED  := 0.55   # faktor usporavanja u limbu

# Collision maske (postavi layere u Project Settings > Physics Layers)
# Layer 1 = ZonaA terrain, Layer 2 = ZonaB terrain, Layer 3 = Limbo objekti
const MASK_ZONE_A := 0b00000101   # layer 1 + layer 3 (limbo objekti vidljivi)
const MASK_ZONE_B := 0b00000110   # layer 2 + layer 3
const MASK_LIMBO  := 0b00000111   # svi layeri — vidi obje zone + limbo

# ─── Stanje ────────────────────────────────────────────────────────────────────
var in_limbo: bool = false
var _spawn_zone: int = 1           # 1 = ZonaA, 2 = ZonaB

# ─── Node reference ────────────────────────────────────────────────────────────
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var limbo_shader_mat: ShaderMaterial = $Sprite2D.material  # opcionalno


# ─── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	add_to_group("player")
	collision_mask = MASK_ZONE_A

	# Povežise na LimboManager signale
	LimboManager.limbo_progress.connect(_on_limbo_progress)
	LimboManager.limbo_ended.connect(_on_limbo_ended)


func _physics_process(delta: float) -> void:
	# Gravitacija
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Horizontalno kretanje
	var dir := Input.get_axis("ui_left", "ui_right")
	var speed := SPEED * (LIMBO_SPEED if in_limbo else 1.0)
	velocity.x = dir * speed

	# Skok (i u limbu može skočiti — po dizajnu)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	move_and_slide()
	_update_animation(dir)


# ─── Limbo API (poziva LimboManager) ──────────────────────────────────────────

func enter_limbo() -> void:
	in_limbo = true
	collision_mask = MASK_LIMBO
	# Vizualni feedback — npr. tint ili shader
	modulate = Color(0.8, 0.7, 1.0, 1.0)


## dest se ignorira za cross-scene teleport (LimboManager već postavi poziciju).
func exit_limbo(dest: Vector2) -> void:
	in_limbo = false

	# Ako je dest != ZERO, to je same-scene teleport
	if dest != Vector2.ZERO:
		global_position = dest

	# Postavi pravi collision mask ovisno o zoni
	collision_mask = MASK_ZONE_B if _spawn_zone == 2 else MASK_ZONE_A

	modulate = Color.WHITE
	velocity = Vector2.ZERO


## Pozovi ovo iz World.gd ili SpawnPoint logike da znaš u kojoj zoni si.
func set_spawn_zone(zone: int) -> void:
	_spawn_zone = zone
	collision_mask = MASK_ZONE_B if zone == 2 else MASK_ZONE_A


# ─── Signali ───────────────────────────────────────────────────────────────────

func _on_limbo_progress(t: float) -> void:
	if not in_limbo:
		return
	# Treperenje u sredini tranzicije
	var flicker := sin(t * PI * 6.0) * 0.15 * sin(t * PI)
	modulate.a = 0.7 + flicker


func _on_limbo_ended() -> void:
	modulate = Color.WHITE


# ─── Animacija ─────────────────────────────────────────────────────────────────

func _update_animation(dir: float) -> void:
	if not is_instance_valid(sprite):
		return

	if not is_on_floor():
		sprite.play("jump")
	elif dir != 0:
		sprite.play("run")
		sprite.flip_h = dir < 0
	else:
		sprite.play("idle")
