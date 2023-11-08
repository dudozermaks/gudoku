extends GridComponentBase
class_name GridShortcutComponent

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
	"func" : func (s : String): grid.toggle_number(int(s))
},
{
	"key" : lefts_array,
	"desc" : "move left",
	"func" : func (_s : String): grid.move_focus(Vector2i(-1, 0))
},
{
	"key" : downs_array,
	"desc" : "move down",
	"func" : func (_s : String): grid.move_focus(Vector2i(0, 1))
},
{
	"key" : ups_array,
	"desc" : "move up",
	"func" : func (_s : String): grid.move_focus(Vector2i(0, -1))
},
{
	"key" : rights_array,
	"desc" : "move right",
	"func" : func (_s : String): grid.move_focus(Vector2i(1, 0))
},
{
	"key" : "c",
	"desc" : "toggle clue mode",
	"func" : func (_s : String): if grid.pencilmark_mode: grid._pencilmark_button_toggled(true)
},
{
	"key" : "p",
	"desc" : "toggle pencilmark mode",
	"func" : func (_s : String): if !grid.pencilmark_mode: grid._pencilmark_button_toggled(true)
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
						var square = grid.get_node("MarginContainer/Grid/Square%d" % [int(s[1]) - 1]) 
						var cell = square.get_child(int(s[2]) - 1)
						grid.focus_on(cell.grid_position),
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
			"func" : func (s : String): grid.highlight_number(int(s))
		},
		{
			"key" : "H",
			"desc" : "remove",
			"func" : func (_s : String): grid.clear_highlight()
		}
	],
},
{
	"key" : "s",
	"desc" : "save",
	"func" : func (_s : String): grid.get_component("File").save_puzzle()
},
]

func process_key(keycode : Key) -> void:
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

func _input(event):
	if event is InputEventKey and\
		event.pressed == true:
			process_key(event.keycode)
