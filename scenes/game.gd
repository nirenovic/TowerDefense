extends Node2D

@onready var camera = %Camera2D
@onready var build_hint = %BuildHint

@export var tile_size: int = 64

var tower_scene = preload("res://scenes/towers/tower.tscn")
var panning: bool = false
var mouse_pos: Vector2
var zoom_step = 0.05

func _ready():
	var tower = tower_scene.instantiate()
	tower.global_position = build_hint.global_position
	build_hint.add_child(tower)
	build_hint.set_collision_shape(tower.get_hitbox())

func _process(delta):
	mouse_pos = get_mouse_global_position()
	if build_hint and mouse_pos:
		#build_hint.global_position = get_closest_tile_position()
		build_hint.global_position = mouse_pos
	
func _input(event):
	if Input.is_action_just_pressed('mouse_right'):
		pass
	if Input.is_action_just_pressed('mouse_left'):
		if can_build_here():
			spawn_tower(build_hint.global_position)

	# camera panning
	if Input.is_action_just_pressed('mouse_middle'):
		panning = true
	if Input.is_action_just_released('mouse_middle'):
		panning = false
	if event is InputEventMouseMotion and panning:
		camera.offset -= event.relative * (1 / camera.zoom.x)

	# zooming
	if Input.is_action_just_pressed('scroll_up'):
		zoom(zoom_step, mouse_pos)
	if Input.is_action_just_pressed('scroll_down'):
		zoom(-zoom_step, mouse_pos)
		
func spawn_tower(pos: Vector2):
	var tower = tower_scene.instantiate()
	add_child(tower)
	tower.build(pos)

func get_mouse_global_position():
	var zoom_offset = 1 / camera.zoom.x
	var zoom_factor = Vector2(zoom_offset, zoom_offset)
	var camera_offset = camera.offset / zoom_offset
	var result = get_viewport().get_mouse_position() - (get_viewport_rect().size / 2) + camera_offset
	return result * zoom_factor
	
func get_closest_tile_position():
	var x = floor(mouse_pos.x) - (floori(mouse_pos.x) % tile_size)
	var y = floor(mouse_pos.y) - (floori(mouse_pos.y) % tile_size)
	var closest = Vector2(x, y)
	return closest

func can_build_here():
	return !build_hint.is_colliding()
	
func zoom(amount: float, pos: Vector2):
	var zoom_vec = Vector2(amount, amount)
	var new_zoom = camera.zoom + zoom_vec
	if new_zoom > Vector2(0, 0) and new_zoom < Vector2(2, 2):
		camera.zoom = new_zoom
	var mouse_offset = get_viewport_rect().get_center() - get_viewport().get_mouse_position() 
	var zoom_factor = 1 / camera.zoom.x
	camera.offset = pos + (mouse_offset * zoom_factor)
