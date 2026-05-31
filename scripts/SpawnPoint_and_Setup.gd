## SpawnPoint.gd
## Stavi na Marker2D node u svakoj sceni.
## Ime nodea mora odgovarati spawn_id u Teleporteru koji šalje igrača ovdje.
## Npr: SpawnFromWorld1, SpawnFromWorld2, SpawnDefault

class_name SpawnPoint
extends Marker2D

## Koja zona pripada ovom spawnu (za collision mask igrača)
## 1 = ZonaA, 2 = ZonaB itd.
@export var player_zone: int = 1

## Prikaži vizualni marker u editoru (ne vidi se u igri)
func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 12.0, Color(0.4, 0.9, 0.6, 0.5))
		draw_arc(Vector2.ZERO, 16.0, 0, TAU, 32, Color(0.4, 0.9, 0.6, 0.8), 2.0)


# ───────────────────────────────────────────────────────────────────────────────

## World.gd
## Stavi na root node svake scene (Node2D).
## Registrira scenu u LimboManageru i spawnira igrača ako ga nema.

# extends Node2D    ← odkommentiraj i kopiraj u vlastiti World.gd fajl

# @export var player_scene: PackedScene
# @onready var spawn_default: SpawnPoint = $SpawnDefault

# func _ready() -> void:
#     LimboManager.register_world(self)
#
#     # Spawnaj igrača samo ako ga LimboManager nije već postavio
#     # (pri cross-scene teleportu, igrač dolazi s njim)
#     var existing := get_tree().get_first_node_in_group("player")
#     if existing == null and player_scene:
#         var p := player_scene.instantiate()
#         add_child(p)
#         p.global_position = spawn_default.global_position
#         p.set_spawn_zone(spawn_default.player_zone)


# ───────────────────────────────────────────────────────────────────────────────
# UPUTE ZA POSTAVLJANJE
# ───────────────────────────────────────────────────────────────────────────────
#
# 1. AUTOLOAD
#    Project > Project Settings > Autoload
#    Dodaj: LimboManager.gd  →  naziv: LimboManager
#
# 2. PHYSICS LAYERS (Project Settings > Physics > 2D)
#    Layer 1: "ZoneA"
#    Layer 2: "ZoneB"
#    Layer 3: "Limbo"
#    Layer 4: "Player"
#    Layer 5: "Enemies"
#
# 3. SCENA STRUKTURA (za svaki World*.tscn)
#
#    World (Node2D) ← World.gd
#    ├── ZonaA (Node2D)
#    │   ├── TileMapLayer    [Physics Layer: 1]
#    │   └── StaticBody2D    [Physics Layer: 1]
#    ├── ZonaB (Node2D)
#    │   ├── TileMapLayer    [Physics Layer: 2]
#    │   └── StaticBody2D    [Physics Layer: 2]
#    ├── LimboObjects (Node2D)
#    │   └── LimboPlatform   [Physics Layer: 3]
#    ├── Teleporter_Exit (Area2D) ← Teleporter.gd
#    │   ├── CollisionShape2D
#    │   └── Sprite2D
#    ├── SpawnDefault (Marker2D) ← SpawnPoint.gd
#    ├── SpawnFromWorld2 (Marker2D) ← SpawnPoint.gd
#    └── LimboOverlay (CanvasLayer, layer=10) ← LimboOverlay.gd
#        └── Panel (ColorRect) ← ShaderMaterial: limbo_blend.gdshader
#
# 4. TELEPORTER INSPECTOR POSTAVKE
#
#    Za cross-scene teleport:
#      target_scene = "res://scenes/World2.tscn"
#      spawn_id     = "SpawnFromWorld1"
#      limbo_duration = 1.5
#
#    Za same-scene teleport:
#      destination_teleporter = <povuci drugi Teleporter node>
#      limbo_duration = 1.0
#
# 5. PLAYER
#    Dodaj igrača u grupu "player" (Node > Groups u Inspectoru)
#    collision_layer = Layer 4 (Player)
