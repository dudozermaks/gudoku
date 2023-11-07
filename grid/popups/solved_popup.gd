extends Popup
class_name SolvedPopup

@onready var text := $Control/MarginContainer/VBoxContainer/Text
@onready var initial_text : String = text.text

func format_text(args : Array):
	text.text = text.text % args

func _on_back_button_pressed():
	hide()

func _on_popup_hide():
	text.text = initial_text
