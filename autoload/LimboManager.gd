## LimboManager.gd
## Autoload singleton — dodaj u Project > Project Settings > Autoload
## Upravlja limbo tranzicijom između scena i unutar iste scene.

extends Node

# ─── Signali ───────────────────────────────────────────────────────────────────
signal limbo_started(duration: float)
signal limbo_progress(t: float)          # 0.0 → 1.0 kroz tranziciju
signal limbo_ended
signal scene_ready                        # nova scena učitana, još u limbu

# ─── Stanje ────────────────────────────────────────────────────────────────────
enum State { NORMAL, LOADING, LIMBO }
var state := State.NORMAL

var _player: Node                         # referenca na igrača
var _elapsed: float = 0.0
var _duration: float = 1.5
var _spawn_id: String = ""               # koji spawn point koristiti u novoj sceni

# Za cross-scene teleport
var _target_scene_path: String = ""
var _loaded_scene: PackedScene = null
var _current_world: Node = null          # kontejner trenutne scene
var _next_world: Node = null             # kontejner nove scene

# Za same-scene teleport
var _same_scene_mode: bool = false
var _destination_pos: Vector2 = Vector2.ZERO

# Referenca na UI overlay (postavi izvana)
var overlay: CanvasLayer = null

# ─── Javno sučelje ─────────────────────────────────────────────────────────────

## Pozovi ovo kad igrač uđe u teleporter koji mjenja scenu.
## spawn_id = ime SpawnPoint nodea u novoj sceni (npr. "SpawnFromA")
func teleport_to_scene(
	player: Node,
	target_scene: String,
	spawn_id: String,
	duration: float = 1.5
) -> void:
	if state != State.NORMAL:
		return

	state = State.LOADING
	_player = player
	_target_scene_path = target_scene
	_spawn_id = spawn_id
	_duration = duration
	_elapsed = 0.0
	_same_scene_mode = false

	_player.enter_limbo()
	limbo_started.emit(duration)

	# Počni učitavati novu scenu u pozadini (ne blokira main thread)
	ResourceLoader.load_threaded_request(target_scene)


## Pozovi ovo za teleport unutar iste scene (stara mehanika ostaje).
func teleport_same_scene(
	player: Node,
	destination: Vector2,
	duration: float = 1.5
) -> void:
	if state != State.NORMAL:
		return

	state = State.LIMBO
	_player = player
	_destination_pos = destination
	_duration = duration
	_elapsed = 0.0
	_same_scene_mode = true

	_player.enter_limbo()
	limbo_started.emit(duration)


# ─── Proces ────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	match state:
		State.LOADING:
			_process_loading(delta)
		State.LIMBO:
			_process_limbo(delta)


func _process_loading(delta: float) -> void:
	# Provjeri je li ResourceLoader završio
	var load_status := ResourceLoader.load_threaded_get_status(_target_scene_path)

	match load_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Još učitava — iskoristi to za limbo vizuale
			# (elapsed raste ali ne završava dok scena nije gotova)
			_elapsed += delta
			var t : float = clamp(_elapsed / (_duration * 0.5), 0.0, 0.95)
			limbo_progress.emit(t)

		ResourceLoader.THREAD_LOAD_LOADED:
			# Scena učitana! Prijeđi u pravi limbo
			_loaded_scene = ResourceLoader.load_threaded_get(_target_scene_path)
			state = State.LIMBO
			scene_ready.emit()

		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("LimboManager: Nije uspjelo učitavanje scene: " + _target_scene_path)
			_abort()


func _process_limbo(delta: float) -> void:
	_elapsed += delta
	var t : float = clamp(_elapsed / _duration, 0.0, 1.0)
	limbo_progress.emit(t)

	if _elapsed >= _duration:
		_finish_limbo()


# ─── Privatne metode ───────────────────────────────────────────────────────────

func _finish_limbo() -> void:
	if _same_scene_mode:
		_player.exit_limbo(_destination_pos)
	else:
		_swap_scenes()

	state = State.NORMAL
	limbo_ended.emit()


func _swap_scenes() -> void:
	if _loaded_scene == null:
		push_error("LimboManager: _loaded_scene je null pri swapu!")
		return

	# Instanciraj novu scenu
	_next_world = _loaded_scene.instantiate()
	get_tree().root.add_child(_next_world)

	# Nađi spawn point
	var spawn := _next_world.find_child(_spawn_id, true, false) as Node2D
	if spawn == null:
		push_error("LimboManager: Spawn point '%s' nije pronađen u novoj sceni!" % _spawn_id)
		spawn = _next_world  # fallback na root poziciju

	# Prebaci igrača
	var player_parent := _player.get_parent()
	player_parent.remove_child(_player)
	_next_world.add_child(_player)

	if spawn is Node2D:
		_player.global_position = (spawn as Node2D).global_position

	_player.exit_limbo(Vector2.ZERO)  # pozicija već postavljena

	# Ukloni staru scenu (defer da engine završi frame)
	if _current_world != null:
		_current_world.queue_free()

	_current_world = _next_world
	_next_world = null
	_loaded_scene = null


func _abort() -> void:
	state = State.NORMAL
	if _player and _player.has_method("exit_limbo"):
		_player.exit_limbo(_player.global_position)
	limbo_ended.emit()


# ─── Inicijalizacija world trackinga ───────────────────────────────────────────

## Pozovi ovo na početku igre da LimboManager zna koja je trenutna scena.
## Obično iz World.gd u _ready().
func register_world(world: Node) -> void:
	_current_world = world
