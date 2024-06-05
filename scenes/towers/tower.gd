extends StaticBody2D

@onready var body = %CollisionShape2D
@onready var health_bar = %HealthBar 
@onready var timer = %Timer

var projectile_scene = preload("res://scenes/towers/projectile.tscn")
var target: Node2D = null
var can_shoot = true
var fire_rate = 2

func _ready():
	timer.wait_time = fire_rate

func _physics_process(delta):
	if target:
		body.look_at(target.global_position)
		if can_shoot:
			shoot(target.global_position)

func shoot(target: Vector2):
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.set_target(target)
	get_tree().root.add_child(projectile)
	can_shoot = false

func _on_detection_zone_body_entered(body):
	if body.is_in_group('enemy') and !target:
		target = body

func _on_timer_timeout():
	can_shoot = true

func _on_detection_zone_body_exited(body):
	if body == target:
		target = null
