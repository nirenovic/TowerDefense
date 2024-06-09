extends Node2D

@onready var camera = %Camera2D
@onready var build_hint = %BuildHint
@onready var destroyer = %Destroyer

@export var tile_size: int = 64
@export var main_menu: Node
@export var ui: Node

var main_menu_scene = preload("res://scenes/user_interface/main_menu.tscn")
var tower_scene = preload("res://scenes/towers/tower.tscn")
var level_scene = preload("res://scenes/level.tscn")
var current_level: Node2D
var panning: bool = false
var mouse_pos: Vector2
var zoom_step = 0.05
var playing = false
var current_mode: String
var current_cursor
var cursor_disabled: bool = false
var cursors: Dictionary

func _ready():
	ui.build_mode.connect(set_mode)
	ui.controls_hover.connect(set_cursor_disabled)
	ui.hide()
	main_menu.start.connect(start_game)
	main_menu.quit.connect(quit)
	cursors['build'] = build_hint
	cursors['destroy'] = destroyer
	var demo_tower = tower_scene.instantiate()
	build_hint.set_hint(demo_tower)

func _process(delta):
	mouse_pos = get_mouse_global_position()
	if current_cursor:
		current_cursor.global_position = mouse_pos
	
func _input(event):
	if playing:
		if Input.is_action_just_pressed('mouse_right'):
			pass
		if Input.is_action_just_pressed('mouse_left'):
			handle_cursor_action()

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
	return build_hint.can_build()
	
func zoom(amount: float, pos: Vector2):
	var zoom_vec = Vector2(amount, amount)
	var new_zoom = camera.zoom + zoom_vec
	if new_zoom > Vector2(0, 0) and new_zoom < Vector2(2, 2):
		camera.zoom = new_zoom
	var mouse_offset = get_viewport_rect().get_center() - get_viewport().get_mouse_position() 
	var zoom_factor = 1 / camera.zoom.x
	camera.offset = pos + (mouse_offset * zoom_factor)

func start_game():
	playing = true
	main_menu.hide()
	ui.show()
	load_level()
	
func quit():
	get_tree().quit()

func is_build_mode():
	return get_current_mode() == 'build'

func load_level():
	current_level = level_scene.instantiate()
	add_child(current_level)

func get_current_mode():
	return current_mode
	
func set_mode(mode):
	if current_mode != mode:
		update_cursor(mode)
		current_mode = mode
		if mode == 'build':
			pass
		if current_mode == 'destroy':
			pass

func is_destroy_mode():
	return get_current_mode() == 'destroy'

func set_cursor_disabled(status):
	cursor_disabled = status
	build_hint.set_disabled(status)
	
func handle_cursor_action():
	if !cursor_disabled:
		if is_build_mode() and can_build_here():
			spawn_tower(build_hint.global_position)

func update_cursor(mode):
	for c in cursors.values():
		c.hide()
	if cursors.keys().has(mode):
		current_cursor = cursors[mode]
		current_cursor.show()
