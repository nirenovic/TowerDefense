extends StaticBody2D

@onready var body = %CollisionShape2D
@onready var health_bar = %HealthBar 
@onready var gun = %Gun
@onready var sprite = %CollisionShape2D/Sprite2D

var target = null

func _ready():
	health_bar.dead.connect(die)

func _physics_process(delta):
	if target:
		body.look_at(target.global_position)
		shoot(target.global_position)
		get_tree().create_timer(2)

func shoot(pos: Vector2):
	gun.shoot(pos)
	
func take_damage(amount):
	health_bar.update_value(-amount)
	
func die():
	queue_free()

func _on_detection_zone_body_entered(body):
	if body.is_in_group('enemy') and !target:
		target = body

func _on_detection_zone_body_exited(body):
	if body == target:
		target = null
