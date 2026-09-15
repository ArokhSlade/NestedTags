@tool extends Control
var object

var definition : NestedTagsDefinition
@onready var editor = %NestedTagsDefinitionEditor


func _on_button_pressed():
	%EditorFileDialog.popup_centered()


func _on_editor_file_dialog_file_selected(path):
	definition = load(path)
	NestedTagsDefinition.initialize_singleton(definition)
	print(str(NestedTagsDefinition.try_get_singleton()))
	editor.set_definition(definition)
	store_project_setting(definition, path)


func store_project_setting(definition, path):
	ProjectSettings.set_setting("nested_tags/nested_tags_definition", path)
	ProjectSettings.save()
