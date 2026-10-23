extends EditorInspectorPlugin

const NestedTagsDefinitionProperty = preload("uid://bcsm62pnnier")
const NESTED_TAGS_DEFINITION_EDITOR = preload("uid://cbo7wtesmkas7")
const NestedTagsDefinitionEditor = preload("uid://bcuoicet56hlj")

const NestedTagsDefinitionDataProperty = preload("uid://d30qox8i2ce4f")

func _can_handle(object):
	if object is NestedTagsDefinition:
		return true
	return true

var parsing_debug_object = false

func _parse_begin(object : Object):
	parsing_debug_object = false
	if "EditorDebuggerRemoteObjects" == object.get_class():
		for prop in object.get_property_list():
			if prop.hint_string == "NestedTagsDefinition":
				parsing_debug_object = true
				return

func _parse_category(object : Object, category : String):
	if object is NestedTagsDefinition:
		if category == "NestedTagsDefinition":
			var definition_editor = NESTED_TAGS_DEFINITION_EDITOR.instantiate()
			add_custom_control(definition_editor)
			definition_editor.set_definition(object)


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: PropertyUsageFlags, wide: bool):
	var prop = object.get(name)
	if prop is NestedTagsDefinition:
		add_property_editor(name, NestedTagsDefinitionProperty.new())
		var definition_editor = NESTED_TAGS_DEFINITION_EDITOR.instantiate()
		definition_editor.set_definition(prop)
	elif object is NestedTagsDefinition:
		if hint_string == "nested_tags_definition_data":
			if TYPE_DICTIONARY == type:
				add_property_editor(name, NestedTagsDefinitionDataProperty.new())
	elif "EditorDebuggerRemoteObjects" == object.get_class():
		if parsing_debug_object:
			if "data" == name:
				if TYPE_DICTIONARY == type:
					add_property_editor(name, NestedTagsDefinitionDataProperty.new())
	return false
