extends EditorProperty

const NESTED_TAGS_DEFINITION_DATA_EDITOR = preload("uid://b02htid877ise")

var nested_tags_definition_data_editor
var updating = false

func _init():
	nested_tags_definition_data_editor = NESTED_TAGS_DEFINITION_DATA_EDITOR.instantiate()
	add_child(nested_tags_definition_data_editor)
	add_focusable(nested_tags_definition_data_editor)


func _update_property():
	var data = get_edited_object()[get_edited_property()]
	if null == data:
		return
	
	updating = true
	
	nested_tags_definition_data_editor.set_data(data)
	updating = false
