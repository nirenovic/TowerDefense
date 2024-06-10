extends Node2D

@onready var particles  = %ExplosionParticles
@onready var audio = %AudioStreamPlayer2D

var audio_finished = false
var particles_finished = false

func _ready():
	audio.play()
	particles.emitting = true
	audio.finished.connect(set_audio_finished)
	particles.finished.connect(set_particles_finished)
	
func _process(delta):
	if audio_finished and particles_finished:
		queue_free()
	
func set_audio_finished():
	audio_finished = true

func set_particles_finished():
	particles_finished = true
