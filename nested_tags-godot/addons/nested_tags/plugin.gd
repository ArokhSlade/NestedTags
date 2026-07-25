@tool
extends EditorPlugin

const NESTED_TAG_INSPECTOR = preload("uid://45fgmuqhruwy")
var tested_tag_inspector

func _enable_plugin():
	add_autoload_singleton("NestedTags", "./nested_tags.tscn")
	tested_tag_inspector = NESTED_TAG_INSPECTOR.new()
	add_inspector_plugin(tested_tag_inspector)

func _disable_plugin():
	remove_autoload_singleton("NestedTags")
	remove_inspector_plugin(tested_tag_inspector)

func _enter_tree():
	# Initialization of the plugin goes here.
	pass


func _exit_tree():
	pass
