extends Sprite2D

var max_scale: Vector2 = Vector2(1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	var rand_scale_factor = randf_range(0.5, 1)
	scale = Vector2(rand_scale_factor, rand_scale_factor)
	max_scale = scale * 2
	rotation = deg_to_rad(randf_range(0, 360))
	
func _physics_process(delta):
	scale = lerp(scale, max_scale, delta * 2)
	if max_scale - scale <= Vector2(0.1, 0.1):
		await get_tree().create_timer(5).timeout
		queue_free()
