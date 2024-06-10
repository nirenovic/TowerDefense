extends Node2D

class_name Projectile

@export var speed: float = 200
@export var hitbox: CollisionShape2D
@export var sprite: Sprite2D
@export var particles: GPUParticles2D
@export var friendly: bool = false
@export var damage: float = 10
@export var homing: bool = false
@export var damage_radius: Area2D
@export var collision_sound_file: AudioStreamMP3
@export var collision_sound_volume: float
@export var collision_sound_pitch: float
@export var collision_sound_rand: float
@export var collision_particles_path: String

var direction: Vector2 = Vector2.ZERO
var target: Node2D
var has_collided = false

func _ready():
	add_to_group('physics_entity')

func _physics_process(delta):
	var velocity = Vector2.ZERO
	if is_homing():
		if target != null:
			set_direction(target.global_position)
	velocity = direction * speed
	global_position += velocity * delta

func set_direction(d: Vector2):
	look_at(d)
	direction = global_position.direction_to(d)
	
func set_target(t: Node2D):
	target = t
	if target.has_signal('died'):
		target.died.connect(free_target)

func free_target():
	target = null 

func is_homing():
	return homing
	
func get_target():
	return target
	
func _on_area_2d_body_entered(body):
	# check correct projectile and body type (e.g. friendly proj. <--> enemy body)
	if has_collided == false:
		if (!friendly and body.is_in_group('friendly')) or (friendly and body.is_in_group('enemy')):
			has_collided = true
			var colliding_bodies = []
			# if projectile has an area-of-effect
			if damage_radius:
				colliding_bodies = damage_radius.get_overlapping_bodies()
			else:
				colliding_bodies.append(body)
			for b in colliding_bodies:
				if b.has_method('take_damage') and b.has_method('is_dead'):
					if !b.is_dead():
						var dist_mod = 1.0
						if damage_radius:
							var dist = global_position.distance_to(b.global_position)
							var max_dist = damage_radius.get_child(0).shape.radius
							dist_mod = 1 - (dist / max_dist)
						b.take_damage(damage * dist_mod)
			if particles:
				particles.emitting = false
			sprite.hide()
			# play destruction sound
			var audio_player = AudioStreamPlayer.new()
			audio_player.pitch_scale = randf_range(collision_sound_pitch - collision_sound_rand, collision_sound_pitch + collision_sound_rand) 
			audio_player.volume_db = randf_range(collision_sound_volume - collision_sound_rand, collision_sound_volume + collision_sound_rand)
			audio_player.stream = collision_sound_file
			add_child(audio_player)
			audio_player.play()
			audio_player.finished.connect(queue_free)
			# spawn collision particles if specified
			if collision_particles_path:
				var collision_particles = load(collision_particles_path).instantiate()
				collision_particles.global_position = body.global_position
				get_tree().root.add_child(collision_particles)
				collision_particles.emitting = true
				collision_particles.finished.connect(collision_particles.queue_free)
