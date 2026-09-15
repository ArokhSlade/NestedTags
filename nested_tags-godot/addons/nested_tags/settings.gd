@tool
extends Node

var _definition : NestedTagsDefinition
var _settings_tab

func get_definition():
	return _definition


func get_definition_filepath():
	return ProjectSettings.get_setting("nested_tags/nested_tags_definition", "")


func _init():
	if not ProjectSettings.has_setting("nested_tags/nested_tags_definition"):
		ProjectSettings.set_setting("nested_tags/nested_tags_definition", "")
	ProjectSettings.set_as_basic("nested_tags/nested_tags_definition", true)
	ProjectSettings.set_as_internal("nested_tags/nested_tags_definition", false)
	# TODO: plugin should not clutter project settings when disabled.
	# remove from project settings on exit. 
	# store & load the last plugin settings with a plugin-specific file 
	# leave it in for now to avoid having to re-set the setting manually frequently


func initialize(settings_tab):
	load_definition_from_project_settings()


func update_definition(path):
	load_definition_from_path(path)
	save_definition_to_project_settings(path)


func load_definition_from_path(path):
	if path.is_empty():
		return
	
	var old_definition = _definition
	
	_definition = load(path)
	if null == _definition:
		_definition = old_definition
	else:
		NestedTagsDefinition.initialize_singleton(_definition)
		print(str(NestedTagsDefinition.try_get_singleton()))
		save_definition_to_project_settings(path)


func save_definition_to_project_settings(path):
	ProjectSettings.set_setting("nested_tags/nested_tags_definition", path)
	ProjectSettings.save()


func load_definition_from_project_settings():
	var path = ProjectSettings.get_setting("nested_tags/nested_tags_definition")
	load_definition_from_path(path)
