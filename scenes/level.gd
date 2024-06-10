extends Node2D

signal enemy_reached
signal fail

@export var spawner: Node2D
@export var end_zone: Node2D
@export var enemies_reached_limit: int = 20
@export var boundary: Area2D

var enemies_reached = 0
var failed = false

func _ready():
	add_to_group('level')
	end_zone.enemy_reached.connect(update_enemies_reached)
	boundary.body_exited.connect(out_of_bounds)
	boundary.area_exited.connect(out_of_bounds)
	
func _physics_process(delta):
	if enemies_reached >= enemies_reached_limit and !failed:
		fail.emit()
		failed = true
	
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
