class_name BuildCursorStrategy
extends BaseCursorStrategy

var collision_shape: CollisionShape2D
var colliding_bodies = []
var colliding_areas = []
var color_build_yes = '#77ff778a'
var color_build_no = '#ff77778a'
var tower_scene = preload("res://scenes/towers/tower.tscn")
var red_tower_strat = preload("res://resources/strategies/towers/red_tower.tres")
var build_hint: Tower

func init(c: Cursor):
	super.init(c)
	
func start():
	build_hint = tower_scene.instantiate()
	build_hint.tower_strategy = red_tower_strat
	if !cursor.get_children().has(build_hint):
		cursor.add_child(build_hint)	
	cursor.set_collision_shape(get_build_hint_collision_shape())
	
func finish():
	if build_hint:
		cursor.remove_child(build_hint)
		build_hint.queue_free()
	
func update():
	set_enabled(can_build_here())
	
func handle_click():
	spawn_tower()
	
func spawn_tower():
	if cursor.get_children().has(build_hint) and can_build_here():
		var tower = tower_scene.instantiate()
		tower.tower_strategy = load("res://resources/strategies/towers/red_tower.tres")
		cursor.get_tree().root.get_child(0).add_child(tower)
		tower.build(build_hint.global_position)

func can_build_here():
	if cursor.get_overlapping_areas():
		for area in cursor.get_overlapping_areas():
			if area.is_in_group('no_build'):
				return false
	if cursor.get_overlapping_bodies().size() > 0:
		return false
		
	return true

func get_build_hint_collision_shape():
	var s: CollisionShape2D = build_hint.get_hitbox().duplicate()
	s.shape.size *= build_hint.scale
	return s
