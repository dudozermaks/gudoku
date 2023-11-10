extends Control

@export var preview_tscn := preload("res://preview/preview.tscn")
@export var insert_to : Control
@export var folder : String

func _ready():
	preview_folder(folder)

func preview_folder(path : String):
	var dir := DirAccess.open(path)
	if dir:
		for file in dir.get_files():
			if file.ends_with(".gudoku"):
				preview_file(path + "/" + file)
	else:
		print("An error occurred when trying to access the path.")

func preview_file(path : String):
	var preview := preview_tscn.instantiate()
	insert_to.add_child(preview)

	preview.grid.get_component("File").load_from_file(path)
	preview.custom_minimum_size = Vector2(0, 400)
