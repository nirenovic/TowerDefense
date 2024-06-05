extends Node2D

@onready var bar = %ProgressBar

@export var health: float = 100

func _ready():
	bar.value = health
	
func _process(delta):
	pass
