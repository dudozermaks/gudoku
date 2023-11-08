extends Button

func _ready():
	pressed.connect(owner.back_to_menu)
