extends Button

func _ready():
	pressed.connect(func(): DisplayServer.clipboard_set(owner.grid.export_clues_as_string()))
