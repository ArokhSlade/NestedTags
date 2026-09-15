@tool
extends EditorPlugin
const NestedTagInspector = preload("uid://45fgmuqhruwy")
var nested_tag_inspector

const NESTED_TAGS_PLUGIN_SETTINGS_TAB = preload("uid://bou2s5kt4dbb")
var nested_tags_plugin_settings_tab

const NESTED_TAGS_DEFINITION_INSPECTOR = preload("uid://ds5nxhwe3g0a8")
var nested_tags_definition_inspector

const NESTED_TAGS = preload("uid://cqm1sstepwtis")
var nested_tags


func _enable_plugin():
	nested_tags_plugin_settings_tab.initialize(nested_tags)
	nested_tags_plugin_settings_tab.refresh()


func _disable_plugin():
	pass


func _enter_tree():
	nested_tag_inspector = NestedTagInspector.new()
	add_inspector_plugin(nested_tag_inspector)
	
	nested_tags_definition_inspector = NESTED_TAGS_DEFINITION_INSPECTOR.new()
	add_inspector_plugin(nested_tags_definition_inspector)
	
	nested_tags_plugin_settings_tab = NESTED_TAGS_PLUGIN_SETTINGS_TAB.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings_tab)
	
	nested_tags = NESTED_TAGS.instantiate()
	add_child(nested_tags)


func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings_tab)
	remove_inspector_plugin(nested_tags_definition_inspector)
	remove_inspector_plugin(nested_tag_inspector)
