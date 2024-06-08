extends Node2D

@onready var timer = %Timer
@onready var sfx_player = %AudioStreamPlayer

@export var fire_rate: float = 1
@export var projectile_scene_path: String = "res://scenes/projectiles/bullet.tscn"
@export var sfx: AudioStream

var projectile_scene: PackedScene = null
var can_fire: bool = false

func _ready():
	can_fire = true
	timer.wait_time = fire_rate
	timer.start()
	projectile_scene = load(projectile_scene_path)
	sfx_player.stream = sfx
	
func shoot(target: Node2D):
	if can_fire:
		sfx_player.play()
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.set_direction(target.global_position)
		if projectile.is_homing():
			projectile.set_target(target)
		get_tree().root.add_child(projectile)
		can_fire = false
		
func _on_timer_timeout():
	can_fire = true
	timer.start()
