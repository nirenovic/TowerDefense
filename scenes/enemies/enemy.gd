extends CharacterBody2D

@onready var speed: float = 50

func _physics_process(delta):
	velocity = Vector2(speed, 0)
	look_at(Vector2(1, 0))
	move_and_slide()
