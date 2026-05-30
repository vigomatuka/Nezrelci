extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var is_attacking := false

func idle() -> void:
	if is_attacking:
		return
	if anim_player.current_animation != "idle":
		anim_player.play("idle")


func run() -> void:
	if is_attacking:
		return
	if anim_player.current_animation != "run":
		anim_player.play("run")


func attack() -> void:
	if is_attacking:
		return
	is_attacking = true
	anim_player.play("attack")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
	
func _ready():
	anim_player.animation_finished.connect(_on_animation_finished)

func get_attack_progress() -> float:
	if anim_player.current_animation != "attack":
		return 0.0
	if anim_player.current_animation_length <= 0.0:
		return 0.0
	return anim_player.current_animation_position / anim_player.current_animation_length
