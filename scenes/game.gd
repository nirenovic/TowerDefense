extends Node2D

@onready var camera = %Camera2D
@onready var build_hint = %BuildHint
@onready var destroyer = %Destroyer

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
var current_mode: String
var current_cursor
var cursor_disabled: bool = false
var cursors: Dictionary
var mouse_moving = false
var last_mouse_pos = Vector2.ZERO

func _ready():
	# ui
	ui.build_mode.connect(set_mode)
	ui.controls_hover.connect(set_cursor_disabled)
	ui.hide()
	# main menu
	main_menu.start.connect(start_game)
	main_menu.quit.connect(quit)
	main_menu.hide()
	# game over menu
	game_over_menu.hide()
	game_over_menu.quit.connect(quit)
	game_over_menu.retry.connect(go_to_main)
	# cursors
	cursors['build'] = build_hint
	cursors['destroy'] = destroyer
	set_cursor(null)
	# placeholders
	var demo_tower = tower_scene.instantiate()
	build_hint.set_hint(demo_tower)
	# init
	go_to_main()

func _process(delta):
	mouse_pos = get_mouse_global_position()
	update_cursor()
	
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
	ui.init()
	load_level()
	
func go_to_main():
	game_over_menu.hide()
	main_menu.show()
	
func quit():
	get_tree().quit()

func is_build_mode():
	return get_current_mode() == 'build'

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

func get_current_mode():
	return current_mode
	
func set_mode(mode):
	if current_mode != mode:
		set_cursor(mode)
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
		elif is_destroy_mode() and destroyer.has_target():
			destroyer.destroy_target()

func set_cursor(mode):
	for c in cursors.values():
		c.hide()
	if cursors.keys().has(mode):
		current_cursor = cursors[mode]
		
func update_cursor():
	if playing and current_cursor:
		current_cursor.show()
		current_cursor.global_position = mouse_pos
		#current_cursor.global_position = get_closest_tile_position()

func game_over():
	playing = false
	set_cursor(null)
	ui.hide()
	game_over_menu.show()
