extends Button

@onready var template_text := text

func _ready():
	pressed.connect(func(): owner.grid.pencilmark_mode = !owner.grid.pencilmark_mode)
	owner.grid.pencilmark_mode_changed.connect(pencilmark_mode_changed)
	pencilmark_mode_changed()

func pencilmark_mode_changed():
	if owner.grid.pencilmark_mode:
		text = template_text % ["on"]
	else:
		text = template_text % ["off"]
