extends Node2D

class_name Projectile

@export var speed: float = 200
@export var hitbox: CollisionShape2D
@export var sprite: Sprite2D
@export var friendly: bool = false
@export var damage: float = 10
@export var homing: bool = false
@export var damage_radius: Area2D

var direction: Vector2 = Vector2.ZERO
var target: Node2D

func _ready():
	pass

func _physics_process(delta):
	var velocity = Vector2.ZERO
	if is_homing():
		if target != null:
			set_direction(target.global_position)
	velocity = direction * speed
	global_position += velocity * delta

func set_direction(d: Vector2):
	look_at(d)
	direction = global_position.direction_to(d)
	
func set_target(t: Node2D):
	target = t
	if target.has_signal('died'):
		target.died.connect(free_target)

func free_target():
	target = null 

func is_homing():
	return homing
	
func get_target():
	return target
	
func _on_area_2d_body_entered(body):
	# check correct projectile and body type (e.g. friendly proj. <--> enemy body)
	if (!friendly and body.is_in_group('friendly')) or (friendly and body.is_in_group('enemy')):
		var colliding_bodies = []
		if damage_radius:
			colliding_bodies = damage_radius.get_overlapping_bodies()
		else:
			colliding_bodies.append(body)
		for b in colliding_bodies:
			if b.has_method('take_damage') and b.has_method('is_dead'):
				if !b.is_dead():
					b.take_damage(damage)
					queue_free()
