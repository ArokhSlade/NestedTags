@tool
extends EditorPlugin
const NestedTagInspector = preload("uid://45fgmuqhruwy")
var nested_tag_inspector

const NESTED_TAGS_PLUGIN_SETTINGS = preload("uid://bou2s5kt4dbb")
var nested_tags_plugin_settings

const NestedTagsDefinitionInspector = preload("uid://ds5nxhwe3g0a8")
var nested_tags_definition_inspector


func _enable_plugin():
	add_autoload_singleton("NestedTags", "./nested_tags.tscn")


func _disable_plugin():
	remove_autoload_singleton("NestedTags")

var test_ui_split = preload("uid://bv3c5ic4iq7a2").instantiate()

func _enter_tree():
	nested_tag_inspector = NestedTagInspector.new()
	add_inspector_plugin(nested_tag_inspector)
	
	nested_tags_definition_inspector = NestedTagsDefinitionInspector.new()
	add_inspector_plugin(nested_tags_definition_inspector)
	
	nested_tags_plugin_settings = NESTED_TAGS_PLUGIN_SETTINGS.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings)
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, test_ui_split)


func _exit_tree():
	remove_inspector_plugin(nested_tag_inspector)
	remove_inspector_plugin(nested_tags_definition_inspector)
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings)
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, test_ui_split)
