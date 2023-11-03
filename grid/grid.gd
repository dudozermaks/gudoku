extends Control
class_name Grid

signal saving_ended

@export var time_label : Label
@export var puzzle_info_label : Label
@export var pencilmark_button : Button
@export var highlight_button : Button
@export var clear_highlight_button : Button
@export var save_button : Button
@export var copy_to_clipboard_button : Button
@export var mobile_numpad : Numpad = null

var time : float = 0
var pencilmark_mode := false
var is_solved := false
var edited := false

var selected_cell := Vector2i(-1, -1)
var highlighted_number : int

var loaded := false
var loaded_puzzle := ""

var is_valid := false

var shortcut_position : Array[int]
var shortcut_string : String

const numbers_array := ["1", "2", "3", "4", "5", "6", "7", "8", "9",
	"kp 1", "kp 2", "kp 3", "kp 4", "kp 5", "kp 6", "kp 7", "kp 8", "kp 9"]
const lefts_array := ["h", "left"]
const downs_array := ["j", "down"]
const ups_array := ["k", "up"]
const rights_array := ["l", "right"]

var shortcuts : Array[Dictionary] = [
{
	"key" : numbers_array,
	"desc" : "toggle number (if pencilmark mode - set pencilmark, else set clue)",
	"func" : func (s : String): toggle_number(int(s))
},
{
	"key" : lefts_array,
	"desc" : "move left",
	"func" : func (_s : String): move_focus(Vector2i(-1, 0))
},
{
	"key" : downs_array,
	"desc" : "move down",
	"func" : func (_s : String): move_focus(Vector2i(0, 1))
},
{
	"key" : ups_array,
	"desc" : "move up",
	"func" : func (_s : String): move_focus(Vector2i(0, -1))
},
{
	"key" : rights_array,
	"desc" : "move right",
	"func" : func (_s : String): move_focus(Vector2i(1, 0))
},
{
	"key" : "c",
	"desc" : "toggle clue mode",
	"func" : func (_s : String): if pencilmark_mode: _pencilmark_button_toggled(true)
},
{
	"key" : "p",
	"desc" : "toggle pencilmark mode",
	"func" : func (_s : String): if !pencilmark_mode: _pencilmark_button_toggled(true)
},
{
	"key" : "m",
	"desc" : "move to",
	"children" : [
		{
			"key" : numbers_array,
			"desc" : "square number",
			"children" : [
				{
					"key" : numbers_array,
					"desc" : "cell number",
					"func" : func (s : String):
						var square = get_node("MarginContainer/Grid/Square%d" % [int(s[1]) - 1]) 
						var cell = square.get_child(int(s[2]) - 1)
						focus_on(cell.grid_position),
				}
			]
		}
	]
},
{
	"key" : "H",
	"desc" : "highlight",
	"children" : [
		{
			"key" : numbers_array,
			"desc" : "number",
			"func" : func (s : String): highlight_number(int(s))
		},
		{
			"key" : "H",
			"desc" : "remove",
			"func" : func (_s : String): clear_highlight()
		}
	],
},
{
	"key" : "s",
	"desc" : "save",
	"func" : func (_s : String): save_puzzle()
},
]

func _process_key(keycode : Key) -> void:
	if keycode == KEY_SHIFT: return
	var key_string := OS.get_keycode_string(keycode)
	if not Input.is_physical_key_pressed(KEY_SHIFT):
		key_string = key_string.to_lower()
	
	shortcut_string += key_string

	var current_shortcuts = shortcuts
	for pos in shortcut_position:
		current_shortcuts = current_shortcuts[pos]["children"]

	for i in range(current_shortcuts.size()):
		var shortcut = current_shortcuts[i]
		if key_string in shortcut["key"]:
			if shortcut.has("func"):
				print("Executing shortcut: " + shortcut_string)
				shortcut["func"].call(shortcut_string)
				shortcut_position.clear()
				shortcut_string = ""
				return
			else:
				shortcut_position.push_back(i)
				return

	shortcut_position.clear()
	shortcut_string = ""

func _ready():
	pencilmark_button.toggled.connect(_pencilmark_button_toggled)
	highlight_button.pressed.connect(func(): if selected_cell != Vector2i(-1, -1): highlight_number(_get_cell(selected_cell).clue))
	clear_highlight_button.pressed.connect(func(): clear_highlight())
	save_button.pressed.connect(func(): save_puzzle())
	copy_to_clipboard_button.pressed.connect(func(): DisplayServer.clipboard_set(export_clues_as_string()))

	if mobile_numpad != null:
		mobile_numpad.number_clicked.connect(func(num : int): _process_key(num + KEY_0))

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

func _input(event):
	if event is InputEventKey and\
		event.pressed == true:
			_process_key(event.keycode)

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
			var cell := _get_cell(Vector2i(col, row))
			var clue : int = int(puzzle[col + row*9])
			if clue != 0:
				cell.clue = clue
				cell.lock()

	loaded = true
	loaded_puzzle = puzzle

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
		_get_cell(selected_cell).focused = false
		selected_cell = Vector2i(-1, -1)
	else:
		if selected_cell != Vector2i(-1, -1):
			_get_cell(selected_cell).focused = false
		selected_cell = pos
		_get_cell(selected_cell).focused = true


func toggle_number(number: int):
	edited = true
	if selected_cell == Vector2i(-1, -1):
		return
	var focused_cell_node := _get_cell(selected_cell)
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

func _get_cell(pos : Vector2) -> Cell:
	return %Grid.find_child("Cell%d%d" % [pos.x, pos.y])
	
func export_clues_as_string(user_pencilmarks := false) -> String:
	var res := ""
	for row in range(0, 9):
		for col in range(0, 9):
			var cell : Cell = _get_cell(Vector2i(col, row))
			if cell.clue != 0 and !(user_pencilmarks and cell.locked):
				res += str(cell.clue)
			else:
				res += "0"
	return res

func export_pencilmarks_as_string() -> String:
	var res := ""
	for row in range(0, 9):
		for col in range(0, 9):
			var cell : Cell = _get_cell(Vector2i(col, row))
			for i in range(1, 10):
				if i in cell.pencilmarks:
					res += str(i)
				else:
					res += "0"

	return res

func export_as_dict() -> Dictionary:
	var res := {}
	res["puzzle_clues"] = loaded_puzzle
	res["user_clues"] = export_clues_as_string(true)
	res["user_pencilmarks"] = export_pencilmarks_as_string()
	res["selected_cell_x"] = selected_cell.x
	res["selected_cell_y"] = selected_cell.y
	res["time"] = time
	return res

func load_from_dict(dict : Dictionary):
	load_puzzle(dict["puzzle_clues"])
	var clues_position := 0
	for row in range(0, 9):
		for col in range(0, 9):
			var cell : Cell = _get_cell(Vector2i(col, row))

			cell.clue = int(dict["user_clues"][clues_position])
			for i in range(0, 9):
				cell.toggle_pencilmark(int(dict["user_pencilmarks"][clues_position*9 + i]))

			clues_position += 1

	var select_cell := Vector2i()
	select_cell.x = dict["selected_cell_x"]
	select_cell.y = dict["selected_cell_y"]
	focus_on(select_cell)
	time = dict["time"]

func save_to_file(save_file_path : String):
	if save_file_path == "":
		# generating new file path based on time
		save_file_path = "user://" + Time.get_datetime_string_from_system() + ".gudoku"
		if FileAccess.file_exists(save_file_path):
			var files_like_this = 1
			save_file_path += str(files_like_this)
			while FileAccess.file_exists(save_file_path):
				files_like_this += 1
				save_file_path[save_file_path.length() - 1] = str(files_like_this)

	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)

	save_file.store_line(JSON.stringify(export_as_dict()))
	print("Saved to " + save_file_path)

func load_from_file(save_file_path : String):
	if not FileAccess.file_exists(save_file_path):
		print("File does not exist")
		return

	var save_file = FileAccess.open(save_file_path, FileAccess.READ)
	var json_string = save_file.get_line()

	var json = JSON.new()
	var parse_result = json.parse_string(json_string)

	if parse_result == null:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	load_from_dict(parse_result)

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

func save_puzzle():
	$FileDialog.popup()
	await $FileDialog.visibility_changed
	
	saving_ended.emit()

func on_exit():
	if !is_solved and edited:
		await	save_puzzle()
