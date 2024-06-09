extends Node2D

signal enemy_reached
signal fail

@export var spawner: Node2D
@export var end_zone: Node2D
@export var enemies_reached_limit: int = 20

var enemies_reached = 0
var failed = false

func _ready():
	end_zone.enemy_reached.connect(update_enemies_reached)
	
func _physics_process(delta):
	if enemies_reached >= enemies_reached_limit and !failed:
		fail.emit()
		failed = true
	
func update_enemies_reached():
	enemies_reached += 1
	enemy_reached.emit(enemies_reached)
