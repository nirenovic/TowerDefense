extends CanvasLayer

signal build_mode
signal controls_hover

@onready var message_label = %MessageLabel
@onready var score_label = %ScoreLabel
@onready var enemies_reached_label = %EnemiesReachedLabel

func _ready():
	set_message_label("")
	
func _process(delta):
	if message_label.text == "":
		message_label.hide()
	else:
		message_label.show()
	
func _on_build_pressed():
	build_mode.emit('build')

func _on_destroy_pressed():
	build_mode.emit('destroy')
	
func _on_repair_pressed():
	build_mode.emit('repair')

func _on_controls_panel_mouse_entered():
	controls_hover.emit(true)

func _on_controls_panel_mouse_exited():
	controls_hover.emit(false)

func set_message_label(new_text):
	message_label.text = new_text

func set_score_label(new_score):
	score_label.text = "Score: " + str(new_score)
	
func set_enemies_reached_label(val):
	enemies_reached_label.text = "Enemies Reached: " + str(val)

func init():
	set_message_label("")
	set_score_label(0)
	set_enemies_reached_label(0)
