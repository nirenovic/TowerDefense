extends CharacterBody2D

@export var speed: float = 200
var target: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO

func _ready():
	pass

func _physics_process(delta):
	if target:
		velocity = direction * speed
		var collision_info = move_and_collide(velocity * delta)
		if collision_info:
			queue_free()
	
func set_target(t: Vector2):
	target = t
	direction = global_position.direction_to(target).normalized()
	look_at(target)
