extends EditorInspectorPlugin


func _can_handle(object):
	return object is NestedTagsDefinition


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	var definition = object as NestedTagsDefinition
	
	
	return true
