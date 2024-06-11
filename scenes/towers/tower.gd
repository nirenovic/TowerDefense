class_name Tower
extends StaticBody2D

@onready var turret = %Turret
@onready var turret_sprite: Sprite2D = %TurretSprite
@onready var health_bar = %HealthBar 
@onready var gun = %Gun
@onready var hitbox = %Hitbox
@onready var detection_zone = %DetectionZone
@onready var base_sprite: Sprite2D = %BaseSprite

@export var tower_strategy: BaseTowerStrategy
@export var damage_particles: GPUParticles2D
@export var destroyed_particles: GPUParticles2D

var target = null
var dead = false
var active = false
var targets_in_range = []
var destroyed = false

func _ready():
	add_to_group('physics_entity')
	add_to_group('tower')
	health_bar.dead.connect(die)
	health_bar.value_changed.connect(update_status)
	tower_strategy.init(self)
	hitbox.disabled = true
	
func _process(delta):
	if active:
		if is_damaged():
			damage_particles.emitting = true
			damage_particles.show()
			if destroyed:
				destroyed_particles.emitting = true
				destroyed_particles.show()
			else:
				destroyed_particles.emitting = false
				destroyed_particles.hide()
		else:
			damage_particles.emitting = false
			damage_particles.hide()
			destroyed_particles.emitting = false
			destroyed_particles.hide()
		
	
func _physics_process(delta):
	if active:
		if !destroyed:
			if target:
				turret.look_at(target.global_position)
				shoot(target)
			else:
				var t = find_closest_target()
				if t:
					set_target(t)

func update_status():
	pass

func shoot(t: Node2D):
	gun.shoot(t)
	
func take_damage(amount):
	health_bar.apply_value(-amount)
	
func die():
	destroyed = true
	var explosion = load("res://scenes/vfx/explosion.tscn").instantiate()
	add_child(explosion)
	turret.hide()
	
func repair():
	health_bar.fully_restore()
	destroyed = false
	turret.show()

func is_dead():
	return destroyed

func _on_detection_zone_body_entered(body):
	if is_enemy(body):
		targets_in_range.append(body)

func _on_detection_zone_body_exited(body):
	if targets_in_range.has(body):
		targets_in_range.erase(body)

func build(pos: Vector2):
	global_position = pos 
	active = true
	hitbox.disabled = false
	collision_layer = 1
	
func is_active():
	return active

func find_closest_target():
	var closest: Node2D
	for t in targets_in_range:
		if !closest:
			closest = t
		var dist = global_position.distance_to(t.global_position)
		if dist < global_position.distance_to(closest.global_position):
			closest = t
			
	return closest

func is_enemy(t: Node2D):
	return t.is_in_group('enemy')

func free_target():
	target = null

func set_target(t):
	if t.has_signal('died'):
		if !t.died.is_connected(free_target):
			t.died.connect(free_target)
	if t.has_method('is_dead'):
		if !t.is_dead():
			target = t 

func get_hitbox():
	return hitbox

func _draw():
	if !active:
		if detection_zone.show_area and detection_zone.area:
			if detection_zone.area.shape is CircleShape2D:
				var points = []
				var radius = detection_zone.radius
				var origin = Vector2(0, radius)
				for point in 360:
					points.append(origin.rotated(deg_to_rad(point)))
				draw_polyline(points, Color(0, 0, 0, 0.05), 10, true)

func is_destroyed():
	return destroyed

func is_damaged():
	return health_bar.get_percentage() < 60

func set_base_texture(t: Texture2D):
	base_sprite.texture = t
	
func set_turret_texture(t: Texture2D):
	turret_sprite.texture = t

func generate_hitbox_shape():
	var rect = RectangleShape2D.new()
	rect.size = base_sprite.get_rect().size
	hitbox.shape = rect
