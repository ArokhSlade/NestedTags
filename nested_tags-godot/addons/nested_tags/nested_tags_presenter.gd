@tool
extends Node

var _model
var _view

func _init():
	if not ProjectSettings.has_setting("nested_tags/nested_tags_definition"):
		ProjectSettings.set_setting("nested_tags/nested_tags_definition", "")
	ProjectSettings.set_as_basic("nested_tags/nested_tags_definition", true)
	# TODO: plugin should not clutter project settings when disabled.
	# remove from project settings on exit. 
	# store & load the last plugin settings with a plugin-specific file 
	# leave it in for now to avoid having to re-set the setting manually frequently


func initialize(model, view):
	_model = model
	_view = view
	_view.definition_file_changed.connect(_on_view_definition_file_changed)
	_model.definition_loaded.connect(_on_model_definition_loaded)
	load_project_setting()


func store_project_setting(path):
	ProjectSettings.set_setting("nested_tags/nested_tags_definition", path)
	ProjectSettings.save()


func load_project_setting():
	var path = ProjectSettings.get_setting("nested_tags/nested_tags_definition")
	try_load_setting(path)


func try_load_setting(path):
	if path.is_empty():
		return
	
	var old_definition = _model.get_definition()
	
	if _model.load_definition(path):
		store_project_setting(path)
	else:
		_model.set_definition(old_definition)


func _on_view_definition_file_changed(path):
	_model.load_definition(path)
	store_project_setting(path)


func _on_model_definition_loaded(definition):
	_view.refresh(definition)
