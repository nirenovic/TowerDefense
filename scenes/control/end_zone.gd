extends Area2D

signal enemy_reached

@export var zone: CollisionShape2D

func _on_body_entered(body):
	if body.is_in_group('enemy'):
		enemy_reached.emit()
		if body.has_method('die'):
			body.die()
