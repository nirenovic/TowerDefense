extends RigidBody2D

@onready var speed: float = 50
@onready var health_bar = %HealthBar
@onready var body = %Body
@onready var gun = %Gun

var projectile_scene = preload("res://scenes/enemies/soldier_projectile.tscn")
var target: Node2D = null
var can_attack = true

func _ready():
	health_bar.dead.connect(die)

func _physics_process(delta):
	var velocity = Vector2.ZERO
	if !target:
		velocity = Vector2(speed, 0)
		body.look_at(Vector2(1, 0))
	else:
		velocity = Vector2.ZERO
		shoot(target.global_position)
		body.look_at(target.global_position)
	global_position += velocity * delta
	
func die():
	queue_free()
	
func shoot(pos: Vector2):
	gun.shoot(pos)

func take_damage(amount):
	health_bar.update_value(-amount)

func _on_detection_zone_body_entered(body):
	if body.is_in_group('tower'):
		target = body
