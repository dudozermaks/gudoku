extends Button

func _ready():
	pressed.connect(owner.grid.get_component("File").export_puzzle)
