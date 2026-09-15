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
	

func _enter_tree():
	if not ProjectSettings.has_setting("nested_tags/nested_tags_definition"):
		ProjectSettings.set_setting("nested_tags/nested_tags_definition", "")
	ProjectSettings.set_as_basic("nested_tags/nested_tags_definition", true)
	# TODO: plugin should not clutter project settings when disabled.
	# remove from project settings on exit. 
	# store & load the last plugin settings with a plugin-specific file 
	# leave it in for now to avoid having to re-set the setting manually frequently
	
	nested_tag_inspector = NestedTagInspector.new()
	add_inspector_plugin(nested_tag_inspector)
	
	nested_tags_definition_inspector = NestedTagsDefinitionInspector.new()
	add_inspector_plugin(nested_tags_definition_inspector)
	
	nested_tags_plugin_settings = NESTED_TAGS_PLUGIN_SETTINGS.instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings)


func _exit_tree():
	remove_inspector_plugin(nested_tag_inspector)
	remove_inspector_plugin(nested_tags_definition_inspector)
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, nested_tags_plugin_settings)
