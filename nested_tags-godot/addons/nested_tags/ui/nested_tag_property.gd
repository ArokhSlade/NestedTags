extends EditorProperty

const NESTED_TAG_CONTROL = preload("uid://fcoq4yaw7nl4")

var nested_tag_control
var current_value : NestedTag = NestedTag.new()
var updating = false

func _init():
	nested_tag_control = NESTED_TAG_CONTROL.instantiate()
	add_child(nested_tag_control)
	add_focusable(nested_tag_control)
	refresh_value_view()
	

func _update_property():
	var tag_id = get_edited_object()[get_edited_property()]
	var definition = NestedTagsDefinition.try_get_singleton()
	if null == definition:
		return
	
	var new_value = definition.get_tag(tag_id)
	if (new_value == current_value):
		return

	updating = true
	current_value = new_value
	refresh_value_view()
	updating = false


func refresh_value_view():
	var definition = NestedTagsDefinition.try_get_singleton()
	nested_tag_control.refresh_tree(definition)
	nested_tag_control.set_tag(current_value)
