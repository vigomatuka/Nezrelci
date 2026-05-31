## Teleporter.gd
## Stavi na Area2D node s CollisionShape2D.
## Podržava i same-scene i cross-scene teleport.

class_name Teleporter
extends Area2D

# ─── Export varijable (podesi u Inspectoru) ────────────────────────────────────

## Traje li tranzicija (sekunde)
@export var limbo_duration: float = 1.5

## --- Same-scene mod ---
## Postavi destination_teleporter za teleport unutar iste scene
@export var destination_teleporter: Teleporter = null

## --- Cross-scene mod ---
## Putanja do druge scene (npr. "res://scenes/World2.tscn")
@export_file("*.tscn") var target_scene: String = ""

## Ime SpawnPoint nodea u ciljnoj sceni
@export var spawn_id: String = "SpawnDefault"

## Koliko sekundi igrač mora čekati prije ponovnog ulaska (anti-spam)
@export var cooldown: float = 0.5

# ─── Interno ───────────────────────────────────────────────────────────────────
var _on_cooldown: bool = false

# ─── Setup ─────────────────────────────────────────────────────────────────────

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _on_cooldown:
		return
	if not body.is_in_group("player"):
		return
	if LimboManager.state != LimboManager.State.NORMAL:
		return

	_start_cooldown()

	# Cross-scene mod ima prioritet
	if target_scene != "":
		LimboManager.teleport_to_scene(
			body,
			target_scene,
			spawn_id,
			limbo_duration
		)
	elif destination_teleporter != null:
		LimboManager.teleport_same_scene(
			body,
			destination_teleporter.global_position,
			limbo_duration
		)
	else:
		push_warning("Teleporter '%s': ni target_scene ni destination_teleporter nije postavljen!" % name)


func _start_cooldown() -> void:
	_on_cooldown = true
	await get_tree().create_timer(cooldown).timeout
	_on_cooldown = false
