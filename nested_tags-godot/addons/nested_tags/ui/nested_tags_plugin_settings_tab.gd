@tool 
extends Control

signal definition_file_changed(path)

const NestedTags = preload("uid://cccga8o21pfq5")

var _definition : NestedTagsDefinition
var _nested_tags : NestedTags

@onready var editor = %NestedTagsDefinitionEditor


func _on_button_pressed():
	%EditorFileDialog.popup_centered()


func initialize(nested_tags):
	_nested_tags = nested_tags


func refresh(definition):
	editor.set_definition(definition)


func _on_editor_file_dialog_file_selected(path):
	definition_file_changed.emit(path)
