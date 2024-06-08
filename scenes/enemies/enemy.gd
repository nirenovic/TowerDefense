extends RigidBody2D

signal died

@export var speed: float = 50
@export var death_particles: GPUParticles2D
@export var death_sprite_scene_path: String

@onready var health_bar = %HealthBar
@onready var model = %Body
@onready var gun = %Gun
@onready var path_marker = %PathMarker

var projectile_scene = preload("res://scenes/enemies/soldier_projectile.tscn")
var target: Node2D = null
var can_attack = true
var path: Path2D
var current_point_index: int
var current_custom_point: Vector2
var velocity: Vector2
var visited_point_indexes = []
var visited_custom_points = []
# path tolerance: pixel distance threshold for counting a path node as visited
var path_tolerance = 30
var dead = false
var custom_path = []
var death_sprite_scene

func _ready():
	health_bar.dead.connect(die)
	generate_custom_path()
	death_sprite_scene = load(death_sprite_scene_path)

func _physics_process(delta):
	if !dead:
		velocity = Vector2.ZERO
		if !target and has_path():
			#follow_path()
			follow_custom_path()
			#body.look_at(get_point_position_global(current_point_index))
			velocity *= speed
		elif target:
			shoot(target)
			model.look_at(target.global_position)
		
		global_position = lerp(global_position, global_position + velocity, delta) 
	
func die():
	died.emit()
	dead = true
	model.scale = Vector2(0, 0)
	await get_tree().create_timer(randf_range(0, 0.2)).timeout
	var death_sprite = death_sprite_scene.instantiate()
	death_sprite.global_position = global_position
	get_tree().root.add_child(death_sprite)
	death_particles.emitting = true
	
func shoot(t: Node2D):
	gun.shoot(t)

func take_damage(amount):
	health_bar.update_value(-amount)

func _on_detection_zone_body_entered(body):
	if body.is_in_group('tower') and body.has_method('is_active'):
		if body.is_active():
			target = body

func set_path(p: Path2D):
	path = p
	current_point_index = 0
	
func has_path():
	return path != null

func follow_path():
	# if another point is closer, make that the current point
	var closest = get_closest_point_index()
	if current_point_index != closest and !has_visited_point(closest):
		current_point_index = closest
	# get current point in path
	var current_point = get_point_position_global(current_point_index)
	var dest = current_point + Vector2(randf_range(-100, 100), randf_range(-100, 100))
	if global_position.distance_to(dest) < path_tolerance:
		visited_point_indexes.append(current_point_index)
		if current_point_index < path.curve.point_count - 1:
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
	
func get_closest_custom_point():
	var closest: Vector2
	for p in custom_path:
		if !closest:
			closest = p
		var dist = global_position.distance_to(p)
		if dist < global_position.distance_to(closest):
			closest = p
	
	return closest

func has_visited_point(index: int):
	return visited_point_indexes.has(index)	
	
func has_visited_custom_point(point: Vector2):
	return visited_custom_points.has(point)
	
func is_dead():
	return dead	

func _on_blood_particles_finished():
	queue_free()
	
func generate_custom_path():
	for point in path.curve.point_count:
		var custom_point = get_point_position_global(point)
		var offset = 50
		custom_point += Vector2(randf_range(-offset, offset), randf_range(-offset, offset))
		custom_path.append(custom_point)
	current_custom_point = custom_path[0]

func follow_custom_path():
	var closest = get_closest_custom_point()
	if current_custom_point != closest and !has_visited_custom_point(closest):
		current_custom_point = closest
	var dest = current_custom_point
	if global_position.distance_to(dest) < randf_range(-path_tolerance, path_tolerance):
		visited_custom_points.append(current_custom_point)
		if custom_path.size() > 1:
			custom_path.pop_front()
			current_custom_point = custom_path[0]
	velocity = global_position.direction_to(dest)
	model.look_at(dest)
	if path_marker:
		path_marker.global_position = dest
