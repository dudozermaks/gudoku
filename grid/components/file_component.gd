extends GridComponentBase
class_name GridFileComponent

signal saving_ended

var file_dialog_tscn := preload("res://file_dialog/file_dialog.tscn")
var save_confirmation_tscn := preload("res://grid/popups_and_confirmations/save_confirmation.tscn")

var filename := ""

func export_as_dict() -> Dictionary:
	var res := {}
	res["puzzle_clues"] = grid.loaded_puzzle
	res["user_clues"] = grid.export_clues_as_string(true)
	res["user_pencilmarks"] = grid.export_pencilmarks_as_string()
	res["selected_cell_x"] = grid.selected_cell.x
	res["selected_cell_y"] = grid.selected_cell.y
	res["time"] = grid.time
	return res

func load_from_dict(dict : Dictionary):
	grid.load_puzzle(dict["puzzle_clues"])
	var clues_position := 0
	for row in range(0, 9):
		for col in range(0, 9):
			var cell : Cell = grid.get_cell(Vector2i(col, row))

			cell.clue = int(dict["user_clues"][clues_position])
			for i in range(0, 9):
				cell.toggle_pencilmark(int(dict["user_pencilmarks"][clues_position*9 + i]))

			clues_position += 1

	var select_cell := Vector2i()
	select_cell.x = dict["selected_cell_x"]
	select_cell.y = dict["selected_cell_y"]
	grid.focus_on(select_cell)
	grid.time = dict["time"]

func export_to_file(save_file_path : String):
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
	filename = save_file_path
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

func save_puzzle():
	var save_confirmation = save_confirmation_tscn.instantiate()
	save_confirmation.confirmed.connect(func():
		if filename == "":
			export_to_file("")
		else:
			export_to_file(filename)
	)
	add_child(save_confirmation)

	save_confirmation.popup()
	await save_confirmation.visibility_changed

	remove_child(save_confirmation)
	
	saving_ended.emit()

func export_puzzle():
	var file_dialog = file_dialog_tscn.instantiate()

	add_child(file_dialog)
	file_dialog.file_selected.connect(export_to_file)

	file_dialog.popup()
	await file_dialog.visibility_changed

	file_dialog.file_selected.disconnect(export_to_file)
	remove_child(file_dialog)
	
	saving_ended.emit()

func save_on_exit():
	if !grid.is_solved and grid.edited:
		await	save_puzzle()
