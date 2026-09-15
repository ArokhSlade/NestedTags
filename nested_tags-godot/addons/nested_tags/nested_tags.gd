@tool
extends Node

signal definition_loaded(definition)

var _definition : NestedTagsDefinition

func get_definition():
	return _definition


func _on_definition_file_changed(path):
	load_definition(path)
	store_project_setting(path)


func _init():
	if not ProjectSettings.has_setting("nested_tags/nested_tags_definition"):
		ProjectSettings.set_setting("nested_tags/nested_tags_definition", "")
	ProjectSettings.set_as_basic("nested_tags/nested_tags_definition", true)
	# TODO: plugin should not clutter project settings when disabled.
	# remove from project settings on exit. 
	# store & load the last plugin settings with a plugin-specific file 
	# leave it in for now to avoid having to re-set the setting manually frequently
	
	load_project_setting()


func store_project_setting(path):
	ProjectSettings.set_setting("nested_tags/nested_tags_definition", path)
	ProjectSettings.save()


func load_definition(path : String):
	if path.is_empty():
		return
		
	_definition = load(path)
	if null == _definition:
		return
		
	NestedTagsDefinition.initialize_singleton(_definition)
	print(str(NestedTagsDefinition.try_get_singleton()))
	definition_loaded.emit(_definition)


func load_project_setting():
	var path = ProjectSettings.get_setting("nested_tags/nested_tags_definition")
	if path.is_empty():
		return
		
	load_definition(path)
