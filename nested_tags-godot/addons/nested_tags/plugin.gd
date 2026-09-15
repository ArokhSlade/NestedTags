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


func _on_nested_tags_plugin_settings_tab_definition_file_changed(path):
	nested_tags._on_definition_file_changed(path)


func _on_nested_tags_definition_loaded(definition):
	nested_tags_plugin_settings_tab.refresh(definition)


func _enter_tree():
	print("enter tree")
	nested_tag_inspector = NestedTagInspector.new()
	add_inspector_plugin(nested_tag_inspector)
	
	nested_tags_definition_inspector = NESTED_TAGS_DEFINITION_INSPECTOR.new()
	add_inspector_plugin(nested_tags_definition_inspector)
	
	nested_tags_plugin_settings_tab = NESTED_TAGS_PLUGIN_SETTINGS_TAB.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings_tab)
	
	nested_tags = NESTED_TAGS.instantiate()
	add_child(nested_tags)

	nested_tags_plugin_settings_tab.definition_file_changed.connect(_on_nested_tags_plugin_settings_tab_definition_file_changed)
	nested_tags.definition_loaded.connect(_on_nested_tags_definition_loaded)
	
	nested_tags.load_project_setting()


func _exit_tree():
	nested_tags.definition_loaded.disconnect(_on_nested_tags_definition_loaded)
	nested_tags_plugin_settings_tab.definition_file_changed.disconnect(_on_nested_tags_plugin_settings_tab_definition_file_changed)
	
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings_tab)
	remove_inspector_plugin(nested_tags_definition_inspector)
	remove_inspector_plugin(nested_tag_inspector)
