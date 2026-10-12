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

var script_editor : ScriptEditor
var editor : CodeEdit

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
	
	script_editor = EditorInterface.get_script_editor()
	script_editor.editor_script_changed.connect(_on_script_editor_editor_script_changed)
	
	add_autoload_singleton("NestedTagsRuntime", "res://addons/nested_tags/nested_tags_runtime.gd")


func print_time():
	print("script changed at %s" % [Time.get_time_string_from_system()])


func _on_script_editor_editor_script_changed(script : Script):
	if editor:
		editor.text_changed.disconnect(print_time)
	
	script_editor = EditorInterface.get_script_editor()
	if script_editor and script_editor.get_current_editor():
		editor = script_editor.get_current_editor().get_base_editor()
	editor.text_changed.connect(print_time)


func _exit_tree():
	remove_autoload_singleton("NestedTagsRuntime")
	
	editor.text_changed.disconnect(print_time)
	script_editor.editor_script_changed.disconnect(_on_script_editor_editor_script_changed)
	
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, settings_tab)
	remove_inspector_plugin(nested_tags_definition_inspector)
	remove_inspector_plugin(nested_tag_inspector)
