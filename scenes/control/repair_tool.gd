extends Area2D

var target: Node2D

func _process(delta):
	if has_target():
		modulate = '#77ff77ff'
	else:
		modulate = '#ffffffff'
		
func _on_body_entered(body):
	if body.is_in_group('friendly') and body is Node2D:
		target = body

func _on_body_exited(body):
	if body == target:
		target = null

func get_target():
	return target 
	
func has_target():
	return !target == null

func repair_target():
	if has_target() and get_target().is_in_group('tower'):
		get_target().repair()
