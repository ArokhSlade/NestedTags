@tool
extends EditorPlugin


func _enable_plugin():
	add_autoload_singleton("NestedTags", "./nested_tags.tscn")


func _disable_plugin():
	remove_autoload_singleton("NestedTags")


func _enter_tree():
	# Initialization of the plugin goes here.
	pass


func _exit_tree():
	pass
