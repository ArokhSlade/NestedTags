extends EditorProperty

const NESTED_TAGS_DEFINITION_EDITOR = preload("uid://cbo7wtesmkas7")

var nested_tags_definition_editor
var updating = false

func _init():
	nested_tags_definition_editor = NESTED_TAGS_DEFINITION_EDITOR.instantiate()
	add_child(nested_tags_definition_editor)
	add_focusable(nested_tags_definition_editor)


func _update_property():
	var definition = get_edited_object()[get_edited_property()]
	if null == definition:
		return
	
	updating = true
	NestedTagsDefinition.initialize_singleton(definition)
	print(str(NestedTagsDefinition.try_get_singleton()))
	nested_tags_definition_editor.set_definition(definition)
	updating = false
