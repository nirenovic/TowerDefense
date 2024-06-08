extends Marker2D

@export var path_to_entity_scene: String = "res://scenes/enemies/soldier.tscn"
@export var spawn_interval: float = 4
@export var path: Path2D

@onready var timer = %Timer

var entity_scene = PackedScene
var enemies = []

func _ready():
	entity_scene = load(path_to_entity_scene)
	spawn()

func _on_timer_timeout():
	spawn()
	
func spawn():
	var entity = entity_scene.instantiate()
	var r = 100
	entity.global_position = global_position + Vector2(randf_range(-r, r), randf_range(-r, r))
	if entity.has_method('set_path'):
		entity.set_path(path)
	get_tree().root.add_child.call_deferred(entity)
	enemies.append(entity)
	timer.wait_time = randf_range(0, spawn_interval)
	timer.start()
