extends Node2D

class_name Projectile

@export var speed: float = 200
@export var hitbox: CollisionShape2D
@export var sprite: Sprite2D
@export var friendly: bool = false
@export var damage: float = 10


var direction: Vector2 = Vector2.ZERO

func _ready():
	pass

func _physics_process(delta):
	var velocity = direction * speed
	global_position += velocity * delta

func set_direction(t: Vector2):
	look_at(t)
	direction = global_position.direction_to(t)

func _on_area_2d_body_entered(body):
	if (!friendly and body.is_in_group('friendly')) or (friendly and body.is_in_group('enemy')):
		if body.has_method('take_damage'):
			body.take_damage(damage)
			queue_free()
