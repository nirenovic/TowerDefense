class_name BaseCursorStrategy
extends Resource

@export var cursor_name: String = "default"
@export var texture: Texture2D = null
var cursor: Cursor
var enabled: bool =true

func init(c: Cursor):
	cursor = c
	
func start():
	pass
	
func finish():
	pass

func handle_click():
	pass

func update():
	pass

func is_enabled():
	return enabled
	
func set_enabled(setting: bool = true):
	enabled = setting

