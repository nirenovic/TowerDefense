extends Node2D

signal dead
signal value_changed

@onready var bar = %ProgressBar

@export var health: float = 100

func _ready():
	hide()
	bar.max_value = health
	bar.value = bar.max_value
	
func update_value(amount):
	bar.value += amount
	
func _on_progress_bar_value_changed(value):
	value_changed.emit()
	if bar.value < bar.max_value:
		show()
	if value <= 0:
		dead.emit()
		hide()
