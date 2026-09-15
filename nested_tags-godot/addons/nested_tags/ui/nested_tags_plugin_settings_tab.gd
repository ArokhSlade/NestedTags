@tool extends Control
var object

var definition : NestedTagsDefinition
@onready var editor = %NestedTagsDefinitionEditor


func _on_button_pressed():
	%EditorFileDialog.popup_centered()


func refresh():
	definition = NestedTags.get_definition()
	editor.set_definition(definition)


func _on_editor_file_dialog_file_selected(path):
	NestedTags.load_definition(path)
	NestedTags.store_project_setting(path)
	refresh()
