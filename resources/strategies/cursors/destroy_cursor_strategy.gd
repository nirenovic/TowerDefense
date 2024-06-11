class_name DestroyCursorStrategy
extends BaseCursorStrategy

var target: Tower

func start():
	var s = CollisionShape2D.new()
	s.shape = RectangleShape2D.new()
	s.shape.size = Vector2(16, 16)
	cursor.set_collision_shape(s)

func update():
	set_enabled(can_destroy())
	print(target)
	
func handle_click():
	if is_enabled() and has_target():
		print(target)
		destroy_target()
	
func can_destroy():
	for body in cursor.get_overlapping_bodies():
		if body is Tower:
			set_target(body)
			return true
	return false

func has_target():
	return target != null
	
func destroy_target():
	target.get_parent().remove_child(target)
	target.queue_free()

func set_target(t: Tower):
	target = t
