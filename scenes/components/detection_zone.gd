extends Area2D

@onready var area = $CollisionShape2D

@export var radius: float = 10

func _ready():
	area.shape.radius = radius
