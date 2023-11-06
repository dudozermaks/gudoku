extends Control
class_name Grid

@export_subgroup("Control Nodes")
@export var time_label : Label
@export var puzzle_info_label : Label
@export var pencilmark_button : Button
@export var highlight_button : Button
@export var clear_highlight_button : Button
@export var copy_to_clipboard_button : Button

@export_subgroup("Components")
@export var file_component : GridFileComponent
@export var shortcut_component : GridShortcutComponent

var time : float = 0
var pencilmark_mode := false
var is_solved := false
var edited := false

var selected_cell := Vector2i(-1, -1)
var highlighted_number : int

var loaded := false
var loaded_puzzle := ""

var is_valid := false

func _ready():
	pencilmark_button.toggled.connect(_pencilmark_button_toggled)
	highlight_button.pressed.connect(func(): if selected_cell != Vector2i(-1, -1): highlight_number(get_cell(selected_cell).clue))
	clear_highlight_button.pressed.connect(func(): clear_highlight())
	copy_to_clipboard_button.pressed.connect(func(): DisplayServer.clipboard_set(export_clues_as_string()))

	for col in range(0, 9):
		for row in range(0, 9):
			@warning_ignore("integer_division")
			var square_number = col/3 + 3 * (row/3)

			var cell = %Grid.get_node("Square%d/Cell%d" % [square_number, col%3 + (row%3)*3])

			cell.name = "Cell%d%d" % [col, row]

			cell.grid_position = Vector2i(col, row)

			cell.clicked.connect(_cell_clicked)
			cell.clue_edited.connect(_on_field_edited)

	focus_on(Vector2i(0, 0))
	clear_highlight()

func _process(delta):
	if !is_solved:
		time += delta
		var minutes := time / 60
		var seconds := fmod(time, 60)
		var milliseconds := fmod(time, 1) * 100
		var time_string := "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
		time_label.text = time_string

static func is_puzzle_valid(puzzle : String) -> bool:
	if puzzle.length() != 81:
		print("Length == %d" % [puzzle.length()])
		return false
	for c in puzzle:
		if !c.is_valid_int():
			print("One of puzzle digits is not digit!")
			return false

	SudokuLib.load_puzzle(puzzle)
	return SudokuLib.is_valid()
	

func move_focus(by : Vector2i):
	if selected_cell == Vector2i(-1, -1):
		focus_on(Vector2i(0, 0))
		return

	var new_pos = selected_cell + by
	new_pos.x = new_pos.x
	new_pos.y = new_pos.y

	if new_pos.x <= -1: new_pos.x = 8
	if new_pos.y <= -1: new_pos.y = 8
	if new_pos.x >= 9: new_pos.x = 0
	if new_pos.y >= 9: new_pos.y = 0

	focus_on(new_pos)

func focus_on(pos : Vector2i):
	if selected_cell == pos:
		get_cell(selected_cell).focused = false
		selected_cell = Vector2i(-1, -1)
	else:
		if selected_cell != Vector2i(-1, -1):
			get_cell(selected_cell).focused = false
		selected_cell = pos
		get_cell(selected_cell).focused = true


func toggle_number(number: int):
	edited = true
	if selected_cell == Vector2i(-1, -1):
		return
	var focused_cell_node := get_cell(selected_cell)
	if pencilmark_mode:
		focused_cell_node.toggle_pencilmark(number)
	else:
		focused_cell_node.clue = number

func clear_highlight():
	var cells := get_tree().get_nodes_in_group("cells")
	for cell in cells:
		cell.highlighted = false
	highlighted_number = -1

func highlight_number(number : int, update := false):
	if highlighted_number == number and !update:
		clear_highlight()
		return

	clear_highlight()

	highlighted_number = number
	var cells := get_tree().get_nodes_in_group("cells")
	for cell in cells:
		if cell.clue == number:
			cell.highlighted = true

func get_cell(pos : Vector2) -> Cell:
	return %Grid.find_child("Cell%d%d" % [pos.x, pos.y])

func load_puzzle(puzzle : String) -> void:
	print("Loading puzzle: " + puzzle)

	is_valid = Grid.is_puzzle_valid(puzzle)

	if is_valid:
		puzzle_info_label.text = "Puzzle is valid\n"

		SudokuLib.load_puzzle(puzzle)
		var puzzle_info : Dictionary = SudokuLib.rate()
		puzzle_info_label.text += "Score: " + str(puzzle_info["score"])
		if !puzzle_info["is_solved"]:
			puzzle_info_label.text += "+\nEngine could not solve this puzzle!"
		puzzle_info_label.text += "\nUsed methods:\n"
		for method in puzzle_info["used_methods"]:
			puzzle_info_label.text += method + "\n"

		SudokuLib.make_solved_copy()

	for row in range(0, 9):
		for col in range(0, 9):
			var cell := get_cell(Vector2i(col, row))
			var clue : int = int(puzzle[col + row*9])
			if clue != 0:
				cell.clue = clue
				cell.lock()

	loaded = true
	loaded_puzzle = puzzle
	
func export_clues_as_string(user_pencilmarks := false) -> String:
	var res := ""
	for row in range(0, 9):
		for col in range(0, 9):
			var cell : Cell = get_cell(Vector2i(col, row))
			if cell.clue != 0 and !(user_pencilmarks and cell.locked):
				res += str(cell.clue)
			else:
				res += "0"
	return res

func export_pencilmarks_as_string() -> String:
	var res := ""
	for row in range(0, 9):
		for col in range(0, 9):
			var cell : Cell = get_cell(Vector2i(col, row))
			for i in range(1, 10):
				if i in cell.pencilmarks:
					res += str(i)
				else:
					res += "0"

	return res

# Signals
func _on_field_edited(cell_edited : Cell):
	if !loaded: return

	if highlighted_number != -1:
		highlight_number(highlighted_number, true)

	SudokuLib.load_puzzle(export_clues_as_string())
	is_solved = SudokuLib.is_solved()

	if is_solved:
		$SolvedPopup.visible = true
		$SolvedPopup.format_text([time_label.text])

	if is_valid and\
		cell_edited.clue != 0 and\
		!SudokuLib.is_right_clue_to_place(cell_edited.grid_position, cell_edited.clue):

		cell_edited.mistaken = true
	elif cell_edited.mistaken:
		cell_edited.mistaken = false

func _cell_clicked(cell : Cell):
	focus_on(cell.grid_position)

func _pencilmark_button_toggled(_button_pressed:bool):
	pencilmark_mode = !pencilmark_mode
	pencilmark_button.text = "Pencilmark\nmode: "

	if pencilmark_mode:
		pencilmark_button.text += "on"
	else:
		pencilmark_button.text += "off"
