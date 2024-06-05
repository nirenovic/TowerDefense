extends Node2D

signal dead

@onready var bar = %ProgressBar

@export var health: float = 100

func _ready():
	bar.value = health
	
func _process(delta):
	pass
	
func update_value(amount):
	bar.value += amount

func _on_progress_bar_value_changed(value):
	if value <= 0:
		dead.emit()
