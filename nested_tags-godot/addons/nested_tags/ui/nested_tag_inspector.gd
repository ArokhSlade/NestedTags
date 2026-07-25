extends EditorInspectorPlugin

const NESTED_TAG_PROPERTY = preload("uid://cikekd0u4xhkm")
var nested_tag_property

func _can_handle(object):
	return true

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if type == TYPE_INT and hint_string == "nested_tag":
		nested_tag_property = NESTED_TAG_PROPERTY.new()
		add_property_editor(name, nested_tag_property)
		return true
	else:
		return false
