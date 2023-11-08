extends Button

func _ready():
	pressed.connect(func():
		if owner.grid.selected_cell != Vector2i(-1, -1): 
			var selected_cell_clue = owner.grid.get_cell(owner.grid.selected_cell).clue
			owner.grid.highlight_number(selected_cell_clue)
	)
