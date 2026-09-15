@tool
extends EditorPlugin


const NestedTagInspector = preload("uid://45fgmuqhruwy")
const SETTINGS_TAB = preload("uid://bou2s5kt4dbb")
const NestedTagsDefinitionInspector = preload("uid://ds5nxhwe3g0a8")
const Settings = preload("uid://cccga8o21pfq5")

var nested_tag_inspector
var settings_tab
var nested_tags_definition_inspector
var settings


func _enter_tree():
	nested_tag_inspector = NestedTagInspector.new()
	add_inspector_plugin(nested_tag_inspector)
	
	nested_tags_definition_inspector = NestedTagsDefinitionInspector.new()
	add_inspector_plugin(nested_tags_definition_inspector)
	
	settings_tab = SETTINGS_TAB.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, settings_tab)
	
	settings = Settings.new()
	settings.initialize(settings_tab)
	add_child(settings)
	
	settings_tab.initialize(settings)
	settings_tab.refresh()


func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, settings_tab)
	remove_inspector_plugin(nested_tags_definition_inspector)
	remove_inspector_plugin(nested_tag_inspector)
