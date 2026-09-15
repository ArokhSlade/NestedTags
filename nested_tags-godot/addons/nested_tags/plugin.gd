@tool
extends EditorPlugin
const NestedTagInspector = preload("uid://45fgmuqhruwy")
var nested_tag_inspector

const NESTED_TAGS_PLUGIN_SETTINGS_TAB = preload("uid://bou2s5kt4dbb")
var nested_tags_plugin_settings_tab

const NESTED_TAGS_DEFINITION_INSPECTOR = preload("uid://ds5nxhwe3g0a8")
var nested_tags_definition_inspector

const NestedTagsPresenter = preload("uid://cccga8o21pfq5")
var presenter
const NestedTagsModel = preload("uid://5kgpf4gwx3qd")
var model

func _enter_tree():
	print("enter tree")
	nested_tag_inspector = NestedTagInspector.new()
	add_inspector_plugin(nested_tag_inspector)
	
	nested_tags_definition_inspector = NESTED_TAGS_DEFINITION_INSPECTOR.new()
	add_inspector_plugin(nested_tags_definition_inspector)
	
	nested_tags_plugin_settings_tab = NESTED_TAGS_PLUGIN_SETTINGS_TAB.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings_tab)
	
	model = NestedTagsModel.new()
	add_child(model)
	presenter = NestedTagsPresenter.new()
	presenter.initialize(model, nested_tags_plugin_settings_tab)
	add_child(presenter)
	
	presenter.load_project_setting()


func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings_tab)
	remove_inspector_plugin(nested_tags_definition_inspector)
	remove_inspector_plugin(nested_tag_inspector)
