extends Marker2D

@export var path_to_entity_scene: String = "res://scenes/enemies/soldier.tscn"
@export var spawn_interval: float = 2
@export var path: Path2D

@onready var timer = %Timer

var entity_scene = PackedScene

func _ready():
	entity_scene = load(path_to_entity_scene)
	timer.wait_time = spawn_interval
	timer.start()

func _on_timer_timeout():
	spawn()
	
func spawn():
	var entity = entity_scene.instantiate()
	entity.global_position = global_position
	if entity.has_method('set_path'):
		entity.set_path(path)
	get_tree().root.add_child(entity)
