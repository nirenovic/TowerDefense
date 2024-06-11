extends Node2D

signal enemy_reached
signal fail

@export var spawner: Node2D
@export var end_zone: Node2D
@export var enemies_reached_limit: int = 20
@export var boundary: Area2D

var enemies_reached = 0
var failed = false
var tree_scene = preload("res://scenes/world_objects/tree.tscn")
var tree_alt_scene = preload("res://scenes/world_objects/tree_alt.tscn")
var rock_scene = preload("res://scenes/world_objects/rock.tscn")
var rock_alt_scene = preload("res://scenes/world_objects/rock_alt.tscn")

func _ready():
	add_to_group('level')
	end_zone.enemy_reached.connect(update_enemies_reached)
	#boundary.body_exited.connect(out_of_bounds)
	boundary.area_exited.connect(out_of_bounds)
	generate_world_objects(200)
	
func _physics_process(delta):
	if enemies_reached >= enemies_reached_limit and !failed:
		fail.emit()
		failed = true
	for zone in get_tree().get_nodes_in_group('no_build_zone'):
		for body in zone.get_overlapping_bodies():
			if body.is_in_group('world_object'):
				body.queue_free()

	
func update_enemies_reached():
	enemies_reached += 1
	enemy_reached.emit(enemies_reached)

func delete_out_of_bounds(bodies):
	pass

func out_of_bounds(entity):
	if entity.get_parent().is_in_group('physics_entity'):
		entity.get_parent().queue_free()
	elif entity.is_in_group('physics_entity'):
		entity.queue_free()

func get_boundary():
	return boundary

func generate_world_objects(amount):
	var bounds = get_boundary()
	var w = bounds.get_child(0).shape.size.x
	var h = bounds.get_child(0).shape.size.y
	var origin = bounds.global_position
	var objects = [tree_scene, tree_alt_scene, rock_scene, rock_alt_scene]
	for i in amount:
		var object = objects[randi_range(0, objects.size() - 1)].instantiate()
		var rand_x = randf_range(origin.x - w/2, origin.x + w/2)
		var rand_y = randf_range(origin.y - h/2, origin.y + h/2)
		object.global_position = Vector2(rand_x, rand_y)
		object.rotation = deg_to_rad(randf_range(0, 360))
		object.scale = Vector2.ONE * randf_range(0.5, 5)
		object.add_to_group('world_object')
		add_child(object)
