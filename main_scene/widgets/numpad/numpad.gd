extends GridContainer

signal number_clicked(num: int)

func _ready():
	for i in range(1, 10):
		get_node(str(i)).pressed.connect(func(): owner.grid.get_component("Shortcut").process_key(i + KEY_0))
