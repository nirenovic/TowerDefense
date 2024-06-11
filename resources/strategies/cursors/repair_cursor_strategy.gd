class_name RepairCursorStrategy
extends BaseCursorStrategy

var target: Tower

func start():
	var s = CollisionShape2D.new()
	s.shape = RectangleShape2D.new()
	s.shape.size = Vector2(16, 16)
	cursor.set_collision_shape(s)

func update():
	set_enabled(can_repair())
	
func handle_click():
	if is_enabled() and can_repair():
		repair_target()
	
func can_repair():
	for body in cursor.get_overlapping_bodies():
		if body is Tower:
			set_target(body)
			return true
	if has_target():
		free_target()
	return false
	
func has_target():
	return target != null

func repair_target():
	target.repair()

func set_target(t: Tower):
	target = t
	target.modulate = cursor.color_enabled
	
func free_target():
	target.modulate = "ffffffff"
	target = null
