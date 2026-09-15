@tool extends Control

const NestedTags = preload("uid://cccga8o21pfq5")

var _definition : NestedTagsDefinition
var _nested_tags : NestedTags

@onready var editor = %NestedTagsDefinitionEditor


func _on_button_pressed():
	%EditorFileDialog.popup_centered()


func initialize(nested_tags):
	_nested_tags = nested_tags


func refresh():
	_definition = _nested_tags.get_definition()
	editor.set_definition(_definition)


func _on_editor_file_dialog_file_selected(path):
	_nested_tags.load_definition(path)
	_nested_tags.store_project_setting(path)
	refresh()
