extends Node2D

signal dead
signal value_changed

@onready var bar = %ProgressBar

@export var health: float = 100

func _ready():
	hide()
	bar.max_value = health
	bar.value = bar.max_value
	
func apply_value(amount):
	bar.value += amount
	if bar.value > bar.max_value:
		bar.value = bar.max_value
	elif bar.value < 0:
		bar.value = 0
	
func _on_progress_bar_value_changed(value):
	value_changed.emit()
	if bar.value < bar.max_value:
		show()
	if value <= 0:
		dead.emit()
		hide()

func get_percentage():
	return (bar.value / bar.max_value) * 100

func fully_restore():
	bar.value = bar.max_value
