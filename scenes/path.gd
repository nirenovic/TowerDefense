extends Path2D

@export var debug: bool = false

var marker_scene = preload("res://scenes/debug/marker.tscn")
var markers = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug:
		for point in curve.point_count:
			var m = marker_scene.instantiate()
			m.global_position = curve.get_point_position(point)
			markers.append(m)
			
		add_markers()
		
func print_points():
	print(curve.point_count)
	for point in curve.point_count:
		print(curve.get_point_position(point))

func add_markers():
	for marker in markers:
		add_child(marker)
