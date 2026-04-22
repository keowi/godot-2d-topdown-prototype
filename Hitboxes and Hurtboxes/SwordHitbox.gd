extends "res://Hitboxes and Hurtboxes/hitbox.gd"



@export var player_node_path: NodePath
var player: Node2D

func _ready():
	player = get_node(player_node_path)

func get_knockback_vector() -> Vector2:
	if player:
		return player.global_position
	else:
		return global_position  # fallback if player isn't assigned
