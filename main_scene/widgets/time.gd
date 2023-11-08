extends RichTextLabel

@export var grid : Grid

@onready var template_text = text

func _ready():
	grid.time_component.time_changed.connect(func():
		var minutes := grid.time / 60
		var seconds := fmod(grid.time, 60)
		var milliseconds := fmod(grid.time, 1) * 100
		text = template_text % [minutes, seconds, milliseconds]
	)
