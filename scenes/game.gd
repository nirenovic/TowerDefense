extends Node2D

@onready var camera = %Camera2D

@export var tile_size: int = 64

var tower_scene = preload("res://scenes/towers/tower.tscn")
var panning: bool = false
var build_hint: Node2D
var mouse_pos: Vector2

func _ready():
	build_hint = tower_scene.instantiate()
	add_child(build_hint)
	
func _input(event):
	mouse_pos = get_mouse_global_position()
	if build_hint and mouse_pos:
		build_hint.global_position = get_closest_tile_position()
	if Input.is_action_just_pressed('mouse_right'):
		pass
	if Input.is_action_just_pressed('mouse_left'):
		spawn_tower(build_hint.global_position)
	if Input.is_action_just_pressed('mouse_middle'):
		panning = true
	if Input.is_action_just_released('mouse_middle'):
		panning = false
	if event is InputEventMouseMotion and panning:
		camera.offset -= event.relative

func spawn_tower(pos: Vector2):
	var tower = tower_scene.instantiate()
	add_child(tower)
	tower.build(pos)

func get_mouse_global_position():
	return camera.offset + get_viewport().get_mouse_position()
	
func get_closest_tile_position():
	var x = floor(mouse_pos.x) - (floori(mouse_pos.x) % tile_size)
	var y = floor(mouse_pos.y) - (floori(mouse_pos.y) % tile_size)
	var closest = Vector2(x, y)
	return closest
