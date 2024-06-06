extends RigidBody2D

@onready var speed: float = 50
@onready var health_bar = %HealthBar
@onready var body = %Body
@onready var gun = %Gun
@onready var path_marker = %PathMarker

var projectile_scene = preload("res://scenes/enemies/soldier_projectile.tscn")
var target: Node2D = null
var can_attack = true
var path: Path2D
var current_point_index: int
var velocity: Vector2
var visited_point_indexes = []
# path tolerance: pixel distance threshold for counting a path node as visited
var path_tolerance = 30

func _ready():
	health_bar.dead.connect(die)

func _physics_process(delta):
	velocity = Vector2.ZERO
	if !target:
		follow_path()
		body.look_at(get_point_position_global(current_point_index))
		global_position += velocity * speed * delta
	else:
		shoot(target.global_position)
		body.look_at(target.global_position)
	
func die():
	queue_free()
	
func shoot(pos: Vector2):
	gun.shoot(pos)

func take_damage(amount):
	health_bar.update_value(-amount)

func _on_detection_zone_body_entered(body):
	if body.is_in_group('tower'):
		target = body

func set_path(p: Path2D):
	path = p
	current_point_index = 0

func follow_path():
	# if another point is closer, make that the current point
	var closest = get_closest_point_index()
	if current_point_index != closest and !has_visited_point(closest):
		current_point_index = closest
	# get current point in path
	var current_point = get_point_position_global(current_point_index)
	var dest = current_point
	if global_position.distance_to(dest) < path_tolerance:
		visited_point_indexes.append(current_point_index)
		current_point_index += 1
	velocity = global_position.direction_to(dest)
	if path_marker:
		path_marker.global_position = dest

func get_point_position_global(index: int):
	var point = path.curve.get_point_position(index)
	return point + path.global_position

func get_closest_point_index():
	var closest: Vector2
	var index = 0
	for p in path.curve.point_count:
		var pos = get_point_position_global(p)
		if !closest:
			closest = pos
		var dist = global_position.distance_to(pos)
		if dist < global_position.distance_to(closest):
			closest = pos
			index = p
	
	return index

func has_visited_point(index: int):
	return visited_point_indexes.has(index)		
