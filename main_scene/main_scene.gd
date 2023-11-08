extends Control

@export var grid : Grid

var menu

func _ready():
	if OS.get_name() in ["Android", "iOS"]: 
		size = get_viewport().get_visible_rect().size

func back_to_menu():
	await grid.get_component("File").save_on_exit()
	menu.visible = true
	queue_free()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		await grid.file_component.save_on_exit()
		get_tree().quit()

	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		back_to_menu()
		
func _enter_tree():
	get_tree().set_auto_accept_quit(false)
	get_tree().set_quit_on_go_back(false)

func _exit_tree():
	get_tree().set_auto_accept_quit(true)
	get_tree().set_quit_on_go_back(true)
