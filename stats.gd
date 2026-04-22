extends Node

@export var max_health := 1
var health := 0 : set = set_health

signal no_health

func _ready():
	health = max_health

func set_health(value: int) -> void:
	health = clamp(value, 0, max_health)

	if health == 0:
		emit_signal("no_health")
