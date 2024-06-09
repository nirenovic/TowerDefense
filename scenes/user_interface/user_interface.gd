extends CanvasLayer

signal build_mode
signal controls_hover

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_build_pressed():
	build_mode.emit('build')


func _on_destroy_pressed():
	build_mode.emit('destroy')

func _on_controls_panel_mouse_entered():
	controls_hover.emit(true)

func _on_controls_panel_mouse_exited():
	controls_hover.emit(false)
