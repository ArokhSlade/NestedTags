@tool extends Control
var object

var definition : NestedTagsDefinition


func _on_button_pressed():
	%EditorFileDialog.popup_centered()


func _on_editor_file_dialog_file_selected(path):
	definition = load(path)
