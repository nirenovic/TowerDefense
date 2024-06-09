extends Area2D

@export var area: CollisionShape2D
@export var radius: float = 10
@export var show_area: bool = false

func _ready():
	if area:
		area.shape.radius = radius
	
