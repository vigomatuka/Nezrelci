## LimboManager3D.gd
## Autoload singleton za 3D teleport između scena.
## Project > Project Settings > Globals (Autoload) > dodaj ovaj fajl, naziv: LimboManager

extends Node

# ─── Signali ───────────────────────────────────────────────────────────────────
signal limbo_started(duration: float)
signal limbo_progress(t: float)
signal limbo_ended

# ─── Stanje ────────────────────────────────────────────────────────────────────
enum State { NORMAL, LOADING, LIMBO }
var state := State.NORMAL

var _player: Node3D
var _elapsed: float = 0.0
var _duration: float = 1.5
var _spawn_id: String = ""
var _target_scene_path: String = ""
var _loaded_scene: PackedScene = null
var _current_world: Node = null

# ─── Javno sučelje ─────────────────────────────────────────────────────────────

func teleport_to_scene(
	player: Node3D,
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

	_player.enter_limbo()
	limbo_started.emit(duration)

	ResourceLoader.load_threaded_request(target_scene)


func register_world(world: Node) -> void:
	_current_world = world


# ─── Proces ────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	match state:
		State.LOADING:
			_process_loading(delta)
		State.LIMBO:
			_process_limbo(delta)


func _process_loading(delta: float) -> void:
	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_target_scene_path)

	match load_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_elapsed += delta
			var t: float = clamp(_elapsed / (_duration * 0.5), 0.0, 0.95)
			limbo_progress.emit(t)

		ResourceLoader.THREAD_LOAD_LOADED:
			_loaded_scene = ResourceLoader.load_threaded_get(_target_scene_path)
			state = State.LIMBO

		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("LimboManager3D: Nije uspjelo učitavanje scene: " + _target_scene_path)
			_abort()


func _process_limbo(delta: float) -> void:
	_elapsed += delta
	var t: float = clamp(_elapsed / _duration, 0.0, 1.0)
	limbo_progress.emit(t)

	if _elapsed >= _duration:
		_finish_limbo()


func _finish_limbo() -> void:
	_swap_scenes()
	state = State.NORMAL
	limbo_ended.emit()


func _swap_scenes() -> void:
	if _loaded_scene == null:
		push_error("LimboManager3D: _loaded_scene je null!")
		return

	var next_world := _loaded_scene.instantiate()
	get_tree().root.add_child(next_world)

	# Nađi spawn point u novoj sceni
	var spawn := next_world.find_child(_spawn_id, true, false) as Node3D
	if spawn == null:
		push_error("LimboManager3D: Spawn '%s' nije pronađen!" % _spawn_id)
		spawn = next_world as Node3D

	# Prebaci igrača u novu scenu
	var old_parent := _player.get_parent()
	old_parent.remove_child(_player)
	next_world.add_child(_player)
	_player.global_position = spawn.global_position

	_player.exit_limbo()

	# Ukloni staru scenu
	if _current_world != null:
		_current_world.queue_free()

	_current_world = next_world


func _abort() -> void:
	state = State.NORMAL
	if _player and _player.has_method("exit_limbo"):
		_player.exit_limbo()
	limbo_ended.emit()
