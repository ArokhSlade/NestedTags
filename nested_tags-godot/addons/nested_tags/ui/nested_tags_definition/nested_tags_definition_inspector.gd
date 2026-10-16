extends EditorInspectorPlugin

const NestedTagsDefinitionProperty = preload("uid://bcsm62pnnier")
const NESTED_TAGS_DEFINITION_EDITOR = preload("uid://cbo7wtesmkas7")
const NestedTagsDefinitionEditor = preload("uid://bcuoicet56hlj")

const NestedTagsDefinitionDataProperty = preload("uid://d30qox8i2ce4f")


var definition_editor : NestedTagsDefinitionEditor
var definition_editor_1 : NestedTagsDefinitionEditor

func _can_handle(object):
	if object is NestedTagsDefinition:
		return true
	return true


func _parse_begin(object):
	if object is NestedTagsDefinition:
		definition_editor = NESTED_TAGS_DEFINITION_EDITOR.instantiate()
		add_custom_control(definition_editor)
		definition_editor.set_definition(object)


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: PropertyUsageFlags, wide: bool):
	const NestedTagsTest = preload("uid://cpqc3q5pgnhgc")
	var prop = object.get(name)
	if prop is NestedTagsDefinition:
	#if object is NestedTagsTest:
		#print("hello object is NestedTagsTest")
		#if name == "definition":
		print("parse property", object, "|", type, "|", name, "|", hint_type, "|", hint_string, "|", usage_flags, "|", wide)
		add_property_editor(name, NestedTagsDefinitionProperty.new())
		#definition_editor_1 = NESTED_TAGS_DEFINITION_EDITOR.instantiate()
		#add_custom_control(definition_editor_1)
		#definition_editor_1.set_definition(prop)
	#elif object is NestedTagsDefinition:
	elif &"data" == name:
			if TYPE_DICTIONARY == type:
				print("data dictionary")
				add_property_editor(name, NestedTagsDefinitionDataProperty.new())
	
	return false
