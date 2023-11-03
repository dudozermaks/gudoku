extends GridContainer
class_name Numpad

signal number_clicked(num: int)

func _ready():
	for i in range(1, 10):
		get_node(str(i)).pressed.connect(func(): number_clicked.emit(i))
