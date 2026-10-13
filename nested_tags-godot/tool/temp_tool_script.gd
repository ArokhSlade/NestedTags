@tool
extends EditorScript

func _run() -> void:
	print_editor_theme_stuff()


static func print_editor_theme_stuff():
	var theme = EditorInterface.get_editor_theme()
	var types = theme.get_icon_type_list()
