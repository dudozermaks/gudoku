extends RichTextLabel

@onready var template_text = text

func _ready():
	owner.grid.get_component("Time").time_changed.connect(func():
		var minutes : int = owner.grid.time / 60
		var seconds := fmod(owner.grid.time, 60)
		var milliseconds := fmod(owner.grid.time, 1) * 100
		text = template_text % [minutes, seconds, milliseconds]
	)
