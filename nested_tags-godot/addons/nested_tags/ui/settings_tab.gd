@tool 
extends Control

const Settings = preload("uid://cccga8o21pfq5")

var _settings : Settings

@onready var editor = %NestedTagsDefinitionEditor


func _on_button_pressed():
	%EditorFileDialog.popup_centered()


func initialize(settings):
	_settings = settings


func refresh():
	var definition = _settings.get_definition()
	editor.set_definition(definition)


func _on_editor_file_dialog_file_selected(path):
	_settings.update_definition(path)
