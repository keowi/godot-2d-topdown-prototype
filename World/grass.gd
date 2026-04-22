extends Node2D

func create_grass_effect() -> void:
	var GrassEffect = load("res://Effects/grass_effect.tscn")
	var grass_effect = GrassEffect.instantiate()
	get_tree().current_scene.add_child(grass_effect)
	grass_effect.global_position = global_position

func _on_hurtbox_area_entered(area: Area2D) -> void:
	create_grass_effect()
	queue_free()
