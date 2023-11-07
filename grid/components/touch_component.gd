extends GridComponentBase
class_name GridTouchComponent

func _ready():
	grid.initialized.connect(func():
		for col in range(0, 9):
			for row in range(0, 9):
				var cell : Cell = grid.get_cell(Vector2i(col, row))
				cell.clicked.connect(_cell_clicked)

		grid.focus_on(Vector2i(0, 0))
	)


func _cell_clicked(cell : Cell):
	grid.focus_on(cell.grid_position)
