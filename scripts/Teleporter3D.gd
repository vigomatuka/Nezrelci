## Teleporter3D.gd
## Prikvači na Area3D node s CollisionShape3D.
## Ovaj skript detektira kad igrač uđe u portal i pokreće tranziciju.

class_name Teleporter3D
extends Area3D

# ─── Export varijable (podesi u Inspectoru) ────────────────────────────────────

## Putanja do ciljne scene (npr. "res://scenes/mario_mapa.tscn")
@export_file("*.tscn") var target_scene: String = ""

## Ime SpawnPoint nodea u ciljnoj sceni (mora se točno podudarati!)
@export var spawn_id: String = "SpawnDefault"

## Trajanje limbo tranzicije u sekundama
@export var limbo_duration: float = 1.5

## Anti-spam: čeka ovaj broj sekundi prije ponovnog aktiviranja
@export var cooldown: float = 0.8

# ─── Interno ───────────────────────────────────────────────────────────────────
var _on_cooldown: bool = false

# ─── Setup ─────────────────────────────────────────────────────────────────────

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _on_cooldown:
		return
	if not body.is_in_group("Player"):
		return
	if LimboManager.state != LimboManager.State.NORMAL:
		return
	if target_scene == "":
		push_warning("Teleporter3D '%s': target_scene nije postavljen!" % name)
		return

	_start_cooldown()
	LimboManager.teleport_to_scene(body, target_scene, spawn_id, limbo_duration)


func _start_cooldown() -> void:
	_on_cooldown = true
	await get_tree().create_timer(cooldown).timeout
	_on_cooldown = false
