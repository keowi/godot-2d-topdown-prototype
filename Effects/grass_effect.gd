extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("Animate")



func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("attack"):
		animated_sprite.play("Animate")


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
