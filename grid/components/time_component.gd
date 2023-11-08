extends GridComponentBase
class_name GridTimeComponent

signal time_changed

func _process(delta):
	if !grid.is_solved:
		grid.time += delta
		time_changed.emit()
