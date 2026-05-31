extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_run() -> void:
	animation_player.play("Armature|mixamo_com|Layer0_010")

func play_attack() -> void:
	animation_player.play("attack")

func is_attack_finished() -> bool:
	return not animation_player.is_playing() or animation_player.current_animation != "attack"
