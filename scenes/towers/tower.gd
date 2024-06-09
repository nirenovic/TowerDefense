extends StaticBody2D

@onready var turret = %Turret
@onready var health_bar = %HealthBar 
@onready var gun = %Gun
@onready var hitbox = %Hitbox
@onready var detection_zone = %DetectionZone

var target = null
var dead = false
var active = false
var targets_in_range = []

func _ready():
	health_bar.dead.connect(die)

func _physics_process(delta):
	if active:
		if target:
			turret.look_at(target.global_position)
			shoot(target)
		else:
			var t = find_closest_target()
			if t:
				set_target(t)

func shoot(t: Node2D):
	gun.shoot(t)
	
func take_damage(amount):
	health_bar.update_value(-amount)
	
func die():
	queue_free()

func is_dead():
	return dead

func _on_detection_zone_body_entered(body):
	if is_enemy(body):
		targets_in_range.append(body)

func _on_detection_zone_body_exited(body):
	if targets_in_range.has(body):
		targets_in_range.erase(body)

func build(pos: Vector2):
	global_position = pos 
	active = true
	hitbox.disabled = false
	collision_layer = 1
	
func is_active():
	return active

func find_closest_target():
	var closest: Node2D
	for t in targets_in_range:
		if !closest:
			closest = t
		var dist = global_position.distance_to(t.global_position)
		if dist < global_position.distance_to(closest.global_position):
			closest = t
			
	return closest

func is_enemy(t: Node2D):
	return t.is_in_group('enemy')

func free_target():
	target = null

func set_target(t):
	if t.has_signal('died'):
		if !t.died.is_connected(free_target):
			t.died.connect(free_target)
	if t.has_method('is_dead'):
		if !t.is_dead():
			target = t 

func get_hitbox():
	return hitbox

func _draw():
	if detection_zone.show_area and detection_zone.area:
		if detection_zone.area.shape is CircleShape2D:
			var points = []
			var radius = detection_zone.radius
			var origin = Vector2(0, radius)
			for point in 360:
				points.append(origin.rotated(deg_to_rad(point)))
			draw_polyline(points, Color(0, 0, 0, 0.05), 10, true)
