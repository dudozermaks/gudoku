extends RichTextLabel

@export var grid : Grid
var invalid_puzzle_message := "Puzzle is invalid, no error checking provided"

func _ready():
	grid.puzzle_loaded.connect(func(info : Dictionary):
		var new_text : String
		if info.is_empty():
			new_text = invalid_puzzle_message
		else:
			new_text = "Puzzle is valid\n"

			new_text += "Score: " + str(info["score"])
			if !info["is_solved"]:
				new_text += "+\nEngine could not solve this puzzle!"
			new_text += "\nUsed methods:\n"
			for method in info["used_methods"]:
				new_text += method + "\n"

		text = text % [new_text]
	)
