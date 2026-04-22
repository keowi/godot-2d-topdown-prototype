extends CharacterBody2D

@onready var stats = $stats

var knockback = Vector2.ZERO
const KNOCKBACK_DECAY = 400.0

func _ready() -> void:
	print(stats.max_health)
	print(stats.health)

func _physics_process(delta: float) -> void:
	# Smoothly reduce knockback
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
	velocity = knockback
	move_and_slide()
	
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.has_method("get_knockback_vector"):
		var direction = (global_position - area.get_knockback_vector()).normalized()
		var strength = 150.0
		knockback = direction * strength

	stats.health -= area.damage

	print(stats.health)


func _on_stats_no_health() -> void:
	queue_free() # Replace with function body.
