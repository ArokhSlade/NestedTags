@tool
extends EditorPlugin

const NESTED_TAG_INSPECTOR = preload("uid://45fgmuqhruwy")
var nested_tag_inspector
const NESTED_TAGS_PLUGIN_SETTINGS = preload("uid://bou2s5kt4dbb")
var nested_tags_plugin_settings

func _enable_plugin():
	add_autoload_singleton("NestedTags", "./nested_tags.tscn")


func _disable_plugin():
	remove_autoload_singleton("NestedTags")
	

func _enter_tree():
	nested_tag_inspector = NESTED_TAG_INSPECTOR.new()
	add_inspector_plugin(nested_tag_inspector)
	nested_tags_plugin_settings = NESTED_TAGS_PLUGIN_SETTINGS.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings)


func _exit_tree():
	remove_inspector_plugin(nested_tag_inspector)
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings)
