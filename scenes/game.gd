extends Node2D

@onready var camera = %Camera2D

var tower_scene = preload("res://scenes/towers/tower.tscn")
var panning: bool = false

func _ready():
	pass

func _process(delta):
	pass
	
func _input(event):
	if Input.is_action_just_pressed('mouse_right'):
		spawn_tower(get_mouse_global_position())
	if Input.is_action_just_pressed('mouse_left'):
		var towers = get_tree().get_nodes_in_group('tower')
		for tower in towers:
			tower.shoot(event.position)
	if Input.is_action_just_pressed('mouse_middle'):
		panning = true
	if Input.is_action_just_released('mouse_middle'):
		panning = false
	if event is InputEventMouseMotion and panning:
		camera.offset -= event.relative

func spawn_tower(pos: Vector2):
	var tower = tower_scene.instantiate()
	tower.global_position = pos
	add_child(tower)

func get_mouse_global_position():
	return camera.offset + get_viewport().get_mouse_position()
