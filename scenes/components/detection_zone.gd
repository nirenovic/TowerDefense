extends Area2D

@export var area: CollisionShape2D
@export var radius: float = 10
@export var show_area: bool = false

func _ready():
	if area:
		area.shape.radius = radius
	
func _draw():
	if show_area and area:
		if area.shape is CircleShape2D:
			draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, 0.1))
