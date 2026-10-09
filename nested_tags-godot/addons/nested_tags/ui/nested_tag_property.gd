extends EditorProperty

const NESTED_TAG_CONTROL = preload("uid://fcoq4yaw7nl4")

var nested_tag_control
var current_tag_id : int ## TODO: currently safer / more idiomatic to use the id of a tag. don't write code that calls ctor directly
var current_tag : NestedTag = null # TODO: invoking the NestedTag ctor is currently semantically wrong and will lead to errors down the line because it will create another object with the same tag id
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
	
	var new_tag = definition.get_tag(tag_id)
	if (new_tag == current_tag):
		return

	updating = true
	current_tag = new_tag
	current_tag_id = new_tag.get_id()
	
	refresh_value_view()
	updating = false


func refresh_value_view():
	var definition = NestedTagsDefinition.try_get_singleton()
	nested_tag_control.refresh_tree(definition)
	if not definition.has_tag(current_tag_id):
		push_error("nested_tag_property::refresh_value_view(): non-existent tag with id %s cannot be disiplayed." % [current_tag_id])
		return
	current_tag = definition.get_tag(current_tag_id)
	nested_tag_control.set_tag(current_tag)
