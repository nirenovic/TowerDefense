extends Node2D

@onready var camera = %Camera2D

@export var tile_size: int = 4
@export var main_menu: Node
@export var game_over_menu: Node
@export var ui: Node

var tower_scene = preload("res://scenes/towers/tower.tscn")
var level_scene = preload("res://scenes/level.tscn")
var current_level: Node2D
var panning: bool = false
var mouse_pos: Vector2
var zoom_step = 0.05
var playing = false
var mouse_moving = false
var last_mouse_pos = Vector2.ZERO
var cursor = preload("res://scenes/control/cursor.tscn")

func _ready():
	# main menu
	main_menu.start.connect(start_game)
	main_menu.quit.connect(quit)
	main_menu.hide()
	# game over menu
	game_over_menu.hide()
	game_over_menu.quit.connect(quit)
	game_over_menu.retry.connect(go_to_main)
	# cursor
	cursor = cursor.instantiate()
	add_child(cursor)
	# ui
	ui.build_mode.connect(cursor.set_mode)
	ui.controls_hover.connect(cursor.set_disabled)
	ui.hide()
	# init
	go_to_main()

func _process(delta):
	mouse_pos = get_mouse_global_position()
	update_cursor()	
	if current_level:
		keep_camera_in_bounds()
	
func _input(event):
	if playing:
		if Input.is_action_just_pressed('mouse_right'):
			pass
		if Input.is_action_just_pressed('mouse_left'):
			cursor.handle_click()

		# camera panning
		if Input.is_action_just_pressed('mouse_middle'):
			panning = true
		if Input.is_action_just_released('mouse_middle'):
			panning = false
		if event is InputEventMouseMotion:
			if panning:
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
	
func zoom(amount: float, pos: Vector2):
	var zoom_vec = Vector2(amount, amount)
	var new_zoom = camera.zoom + zoom_vec
	if new_zoom > Vector2(0, 0) and new_zoom < Vector2(2, 2):
		var mouse_offset = get_viewport_rect().get_center() - get_viewport().get_mouse_position() 
		var zoom_factor = 1 / new_zoom.x
		var new_offset = pos + (mouse_offset * zoom_factor)
		if camera_is_in_bounds(new_zoom, new_offset):
			camera.zoom = new_zoom
			camera.offset = new_offset

func start_game():
	playing = true
	main_menu.hide()
	ui.show()
	ui.init()
	load_level()
	
func go_to_main():
	game_over_menu.hide()
	main_menu.show()
	
func quit():
	get_tree().quit()

func load_level():
	if current_level:
		remove_child(current_level)
		current_level.queue_free()
		for e in get_tree().root.get_children():
			if e.name != "Game":
				get_tree().root.remove_child(e)
				e.queue_free()
	current_level = level_scene.instantiate()
	current_level.enemy_reached.connect(ui.set_enemies_reached_label)
	current_level.fail.connect(game_over)
	add_child(current_level)
		
func update_cursor():
	if playing and cursor:
		cursor.show()
		cursor.global_position = mouse_pos
		#current_cursor.global_position = get_closest_tile_position()

func game_over():
	playing = false
	ui.hide()
	game_over_menu.show()

func keep_camera_in_bounds():
	var camera_left = camera.offset.x - ((get_viewport_rect().size.x / 2) * (1 / camera.zoom.x))
	var camera_right = camera.offset.x + ((get_viewport_rect().size.x / 2) * (1 / camera.zoom.x))
	var camera_top = camera.offset.y - ((get_viewport_rect().size.y / 2) * (1 / camera.zoom.y))
	var camera_bottom = camera.offset.y + ((get_viewport_rect().size.y / 2) * (1 / camera.zoom.y))
	
	var bounds = current_level.get_boundary()
	var bounds_left = bounds.global_position.x - bounds.get_child(0).shape.size.x / 2
	var bounds_right = bounds.global_position.x + bounds.get_child(0).shape.size.x / 2
	var bounds_top = bounds.global_position.y - bounds.get_child(0).shape.size.y / 2
	var bounds_bottom = bounds.global_position.y + bounds.get_child(0).shape.size.y / 2
	
	var offset_left = abs(camera_left - bounds_left)
	var offset_right = abs(camera_right - bounds_right)
	var offset_top = abs(camera_top - bounds_top)
	var offset_bottom = abs(camera_bottom - bounds_bottom)
	
	var out_left = camera_left < bounds_left
	var out_right = camera_right > bounds_right
	var out_top = camera_top < bounds_top
	var out_bottom = camera_bottom > bounds_bottom
	
	if !(out_left and out_right):
		if out_left:
			camera.offset.x += offset_left
		elif out_right:
			camera.offset.x -= offset_right
	else:
		zoom(zoom_step, mouse_pos)
			
	if !(out_top and out_bottom):
		if out_top:
			camera.offset.y += offset_top
		elif out_bottom:
			camera.offset.y -= offset_bottom
	else:
		zoom(zoom_step, mouse_pos)	

func camera_is_in_bounds(zoom: Vector2, offset: Vector2, strict: bool = false):
	var camera_left = offset.x - ((get_viewport_rect().size.x / 2) * (1 / zoom.x))
	var camera_right = offset.x + ((get_viewport_rect().size.x / 2) * (1 / zoom.x))
	var camera_top = offset.y - ((get_viewport_rect().size.y / 2) * (1 / zoom.y))
	var camera_bottom = offset.y + ((get_viewport_rect().size.y / 2) * (1 / zoom.y))
	
	var bounds = current_level.get_boundary()
	var bounds_left = bounds.global_position.x - bounds.get_child(0).shape.size.x / 2
	var bounds_right = bounds.global_position.x + bounds.get_child(0).shape.size.x / 2
	var bounds_top = bounds.global_position.y - bounds.get_child(0).shape.size.y / 2
	var bounds_bottom = bounds.global_position.y + bounds.get_child(0).shape.size.y / 2
	
	var offset_left = abs(camera_left - bounds_left)
	var offset_right = abs(camera_right - bounds_right)
	var offset_top = abs(camera_top - bounds_top)
	var offset_bottom = abs(camera_bottom - bounds_bottom)
	
	var out_left = camera_left < bounds_left
	var out_right = camera_right > bounds_right
	var out_top = camera_top < bounds_top
	var out_bottom = camera_bottom > bounds_bottom
	
	var y_ok = (!out_top and !out_bottom) and (!out_left or !out_right)
	var x_ok = (!out_left and !out_right) and (!out_top or !out_bottom)
	
	return y_ok or x_ok
