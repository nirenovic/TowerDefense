extends Area2D

var collision_shape: CollisionShape2D
var colliding_bodies = []
var colliding_areas = []
var color_build_yes = '#77ff778a'
var color_build_no = '#ff77778a'

func _ready():
	modulate = color_build_yes
	
func _physics_process(delta):
	if is_colliding():
		modulate = color_build_no
	else:
		modulate = color_build_yes

func set_collision_shape(s: CollisionShape2D):
	if !collision_shape:
		collision_shape = s.duplicate()
		add_child(collision_shape)
		collision_shape.show()
	
func get_collision_shape() -> CollisionShape2D:
	return collision_shape

func _on_body_entered(body):
	colliding_bodies.append(body)

func _on_body_exited(body):
	if colliding_bodies.has(body):
		colliding_bodies.erase(body)

func _on_area_entered(area):
	if area.is_in_group('no_build'):
		colliding_areas.append(area)

func _on_area_exited(area):
	if colliding_areas.has(area):
		colliding_areas.erase(area)

func has_colliding_bodies():
	return colliding_bodies.size() > 0

func has_colliding_areas():
	return colliding_areas.size() > 0
	
func is_colliding():
	return has_colliding_bodies() or has_colliding_areas()
