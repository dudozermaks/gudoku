extends Control

func _ready():
	%GenerateButton.grab_focus()
	OS.request_permissions()
	# if OS.get_name() in ["Android", "iOS"]: 
	# 	$LoadFileButton.disabled = true


func _load_grid():
	var game_scene
	if OS.get_name() in ["Android", "iOS"]: 
		game_scene = load("res://main_scene/mobile.tscn").instantiate()
	else:
		game_scene = load("res://main_scene/pc.tscn").instantiate()

	get_tree().get_root().add_child(game_scene)
	game_scene.menu = self
	return game_scene

func _on_load_string_button_pressed():
	var game_scene = _load_grid()
	game_scene.grid.load_puzzle(%PuzzleTextEdit.text.strip_edges())
	visible = false

func _on_load_file_button_pressed():
	$FileDialog.popup()

func _on_load_file_dialog_file_selected(path:String):
	var game_scene = _load_grid()
	game_scene.grid.file_component.load_from_file(path)
	visible = false

func _on_generate_button_pressed():
	var game_scene = _load_grid()
	game_scene.grid.load_puzzle(SudokuLib.generate())
	visible = false
