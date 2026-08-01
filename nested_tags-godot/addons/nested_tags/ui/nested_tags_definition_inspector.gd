extends EditorInspectorPlugin

const NestedTagsDefinitionProperty = preload("uid://bcsm62pnnier")
const NESTED_TAGS_DEFINITION_EDITOR = preload("uid://cbo7wtesmkas7")
const NestedTagsDefinitionEditor = preload("uid://bcuoicet56hlj")

var definition_editor : NestedTagsDefinitionEditor

func _can_handle(object):
	if object is NestedTagsDefinition:
		return true
	return false


func _parse_begin(object):
	if object is NestedTagsDefinition:
		definition_editor = NESTED_TAGS_DEFINITION_EDITOR.instantiate()
		add_custom_control(definition_editor)
		definition_editor.set_definition(object)
