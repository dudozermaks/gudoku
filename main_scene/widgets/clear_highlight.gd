extends Button

func _ready():
	pressed.connect(owner.grid.clear_highlight)
