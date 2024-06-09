extends CanvasLayer

signal retry
signal quit


func _on_main_menu_button_pressed():
	retry.emit()

func _on_quit_button_pressed():
	quit.emit()
