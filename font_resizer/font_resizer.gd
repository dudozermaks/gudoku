extends Node
class_name FontResizer

# This script provides help with font resizing when viewport size changes.
# Script changes default font size of all type names in given themes, when viewport size changed.

enum SCALE_METHOD {
	AVERAGE_SIZE,
	MIN_SIDE_SIZE,
}

@export var themes_to_resize : Array[Theme]
@export var scale_method : SCALE_METHOD = SCALE_METHOD.MIN_SIDE_SIZE
@export var custom_default_viewport_size := Vector2.ZERO
# this script will save default font size of type_name into the font_size property with this name
@export var property_mask : String = "__default_"

var default_viewport_size :Vector2

var font_scale = 1

func _ready():
	get_tree().get_root().size_changed.connect(_calculate_and_apply_scale)

	if custom_default_viewport_size == Vector2.ZERO:
		default_viewport_size = Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height")
		)
	else:
		default_viewport_size = custom_default_viewport_size

	for theme in themes_to_resize:
		for type_name in theme.get_font_size_type_list():
			for font_size_name in theme.get_font_size_list(type_name):
				_set_default_font_size(theme, type_name, font_size_name)

	_calculate_and_apply_scale()

func _calculate_and_apply_scale():
	var current_viewport_size : Vector2 = get_viewport().get_visible_rect().size
	var viewport_ratio : Vector2 = current_viewport_size / default_viewport_size

	match scale_method:
		SCALE_METHOD.AVERAGE_SIZE:
			font_scale = (viewport_ratio.x + viewport_ratio.y) / 2
		SCALE_METHOD.MIN_SIDE_SIZE:
			if viewport_ratio.x < viewport_ratio.y:
				font_scale = viewport_ratio.x
			else:
				font_scale = viewport_ratio.y

	for theme in themes_to_resize:
		_update_theme(theme)

func _update_theme(theme : Theme):
	for type_name in theme.get_font_size_type_list():
			for font_size_name in theme.get_font_size_list(type_name):
				if font_size_name.begins_with(property_mask): continue
				theme.set_font_size(font_size_name, type_name, _get_default_font_size(theme, type_name, font_size_name) * font_scale)

func _get_default_font_size(theme : Theme, type_name : String, font_size_name : String) -> int:
	return theme.get_font_size(property_mask + font_size_name, type_name)

func _set_default_font_size(theme : Theme, type_name : String, font_size_name : String):
	theme.set_font_size(property_mask + font_size_name, type_name, theme.get_font_size(font_size_name, type_name))

func _clear_default_font_size(theme : Theme, type_name : String, font_size_name : String):
	theme.clear_font_size(property_mask + font_size_name, type_name)

# clean-up
func _exit_tree():
	for theme in themes_to_resize:
		for type_name in theme.get_font_size_type_list():
			for font_size_name in theme.get_font_size_list(type_name):
				_clear_default_font_size(theme, type_name, font_size_name)
