class_name Cursor
extends Area2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

@export var cursor_strategies: Array[BaseCursorStrategy]

var current_mode: BaseCursorStrategy
var enabled: bool = true
var modes: Dictionary
var color_enabled = '#77ff778a'
var color_disabled = '#ff77778a'
var overlapping_bodies = []
var overlapping_areas = []

func _ready():
	for strategy in cursor_strategies:
		strategy.init(self)
		modes[strategy.cursor_name] = strategy
	set_mode('build')
	
func _process(delta):
	if is_enabled() and current_mode.is_enabled():
		modulate = color_enabled
	else:
		modulate = color_disabled

func _physics_process(delta):
	current_mode.update()

func handle_click():
	if is_enabled() and current_mode.is_enabled():
		current_mode.handle_click()

func set_mode(mode: String):
	if modes.keys().has(mode):
		if current_mode:
			current_mode.finish()
		current_mode = modes[mode]
		current_mode.start()
		if current_mode.texture:
			sprite.texture = current_mode.texture

func get_modes():
	return modes

func get_current_mode():
	return current_mode.cursor_name

func is_enabled():
	return enabled

func set_enabled(setting: bool = true):
	enabled = setting
	
func set_disabled(setting: bool = true):
	enabled = !setting

func _on_area_entered(area):
	overlapping_areas.append(area)

func _on_area_exited(area):
	if overlapping_areas.has(area):
		overlapping_areas.erase(area)
		
func _on_body_entered(body):
	overlapping_bodies.append(body)

func _on_body_exited(body):
	if overlapping_bodies.has(body):
		overlapping_bodies.erase(body)

func _get_overlapping_bodies():
	return overlapping_bodies
	
func _get_overlapping_areas():
	return overlapping_areas

func set_collision_shape(s: CollisionShape2D):
	collision_shape.shape = s.shape
