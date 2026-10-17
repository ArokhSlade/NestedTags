@tool
extends EditorPlugin

const NestedTagInspector = preload("uid://45fgmuqhruwy")
const SETTINGS_TAB = preload("uid://bou2s5kt4dbb")
const SettingsTab = preload("uid://xqwew7j5j6rh")
const NestedTagsDefinitionInspector = preload("uid://ds5nxhwe3g0a8")
const Settings = preload("uid://cccga8o21pfq5")

var nested_tag_inspector
var settings_tab : SettingsTab
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
	settings_tab.name = "Nested Tag Settings"
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, settings_tab)
	
	settings = Settings.new()
	settings.initialize()
	add_child(settings)
	
	settings_tab.initialize(settings)
	settings_tab.refresh()
	
	#add_autoload_singleton(singleton_name, )
	
	script_editor = EditorInterface.get_script_editor()
	script_editor.editor_script_changed.connect(_on_script_editor_editor_script_changed)


func print_time():
	#print("script changed at %s" % [Time.get_time_string_from_system()])
	pass


func _on_script_editor_editor_script_changed(script : Script):
	if editor:
		editor.text_changed.disconnect(print_time)
		editor.code_completion_requested.disconnect(_on_editor_code_completion_requested)
	
	script_editor = EditorInterface.get_script_editor()
	if script_editor and script_editor.get_current_editor():
		editor = script_editor.get_current_editor().get_base_editor()
		editor.text_changed.connect(print_time)
		editor.code_completion_requested.connect(_on_editor_code_completion_requested)


func _on_editor_code_completion_requested():
	print("_on_editor_code_completion_requested")
	var text := editor.get_text_for_code_completion()
	var sections = text.split(char(0xFFFF))
	var left = sections[0]
	var right = sections[1]
	if left.ends_with("HiTags.get(\""):
		editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, "mytag.yourtag.hello.world", "mytag.yourtag.hello.world")
		editor.update_code_completion_options(true)


func _exit_tree():
	if editor:
		editor.text_changed.disconnect(print_time)
		editor.code_completion_requested.disconnect(_on_editor_code_completion_requested)
	
	script_editor.editor_script_changed.disconnect(_on_script_editor_editor_script_changed)
	
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, settings_tab)
	remove_inspector_plugin(nested_tags_definition_inspector)
	remove_inspector_plugin(nested_tag_inspector)
