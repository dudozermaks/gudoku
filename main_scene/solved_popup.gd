extends Popup

@onready var text := $Control/MarginContainer/VBoxContainer/Text

func format_text(args : Array):
	text.text = text.text % args

func _on_back_button_pressed():
	visible = false
