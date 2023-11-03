class_name Cell
extends Control

signal clue_edited(Cell)
signal clicked(Cell)

var grid_position : Vector2i

var locked := false
var focused := false :
	set (new):
		focused = new
		$FocusShade.visible = new
var highlighted := false :
	set (new):
		highlighted = new
		$HighlightBG.visible = new
		if new: add_to_group("highlighted")
		else: remove_from_group("highlighted")

var mistaken := false:
	set (new):
		mistaken = new
		$MistakenBG.visible = new

var clue := 0 :
	set = set_clue


var pencilmarks : Array[int]

func _ready():
	$FocusShade.visible = false

func toggle_pencilmark(pencilmark_to_set : int) -> void:
	if locked: return
	if $Clue.text != "": return
	if not (pencilmark_to_set in range(1, 10)): return
	if pencilmark_to_set in pencilmarks:
		pencilmarks.erase(pencilmark_to_set)
	else:
		pencilmarks.push_back(pencilmark_to_set)
	
	pencilmarks.sort()
	
	$Pencilmarks.text = ""
	for p in pencilmarks:
		$Pencilmarks.text += str(p) + " "

	# only right edge
	$Pencilmarks.text = $Pencilmarks.text.strip_edges(false, true)

func set_clue(clue_to_set : int) -> void:
	if locked: return
	if not clue_to_set in range(1, 10): return

	if clue == clue_to_set:
		clue = 0
		$Clue.text = ""
		$Pencilmarks.visible = true
	else:
		clue = clue_to_set
		$Clue.text = str(clue_to_set)
		$Pencilmarks.visible = false

	clue_edited.emit(self)

func lock():
	locked = true
	$Clue.add_theme_color_override(
		"font_color", 
		get_theme_color("font_color_locked", "Label")
	)

func _input(event):
	if event is InputEventMouseButton\
		and event.button_index == MOUSE_BUTTON_LEFT\
		and event.pressed\
		and get_global_rect().has_point(event.position):
		clicked.emit(self)
