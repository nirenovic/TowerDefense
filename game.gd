extends Node2D

var tower_scene = preload("res://tower.tscn")

func _ready():
	pass

func _process(delta):
	pass
	
func _input(event):
	if Input.is_action_just_pressed('mouse_right'):
		spawn_tower(event.position)

func spawn_tower(pos: Vector2):
	var tower = tower_scene.instantiate()
	tower.global_position = pos
	add_child(tower)
