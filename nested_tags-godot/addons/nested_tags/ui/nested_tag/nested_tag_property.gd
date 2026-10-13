extends EditorProperty

const NESTED_TAG_EDITOR = preload("uid://fcoq4yaw7nl4")

var nested_tag_editor
var current_tag_id : int # TODO: currently safer / more idiomatic to use the id of a tag. don't write code that calls ctor directly
var current_tag : NestedTag = null # TODO: invoking the NestedTag ctor is currently semantically wrong and will lead to errors down the line because it will create another object with the same tag id

var definition

func _init():
	if not definition:
		# TODO: let users choose the definition for a given property?
		definition = NestedTagsDefinition.try_get_singleton()
	
	nested_tag_editor = NESTED_TAG_EDITOR.instantiate()
	add_child(nested_tag_editor)
	add_focusable(nested_tag_editor)
	refresh_value_view()
	nested_tag_editor.tag_selected.connect(_on_nested_tag_editor_tag_selected)


func _on_nested_tag_editor_tag_selected(tag):
	if current_tag == tag:
		return
	
	current_tag = tag
	current_tag_id = current_tag.id
	emit_changed(get_edited_property(), current_tag_id)
	
	nested_tag_editor.refresh_button(definition, current_tag)
	


func _update_property():
	var tag_id = get_edited_object()[get_edited_property()]
	
	if null == definition:
		return
	
	var new_tag = definition.get_tag(tag_id)
	if (new_tag == current_tag):
		return

	current_tag = new_tag
	current_tag_id = new_tag.get_id()
	
	refresh_value_view()


func refresh_value_view():
	if not definition.has_tag(current_tag_id):
		push_error("nested_tag_property::refresh_value_view(): non-existent tag with id %s cannot be disiplayed." % [current_tag_id])
		return
	current_tag = definition.get_tag(current_tag_id)
	nested_tag_editor.refresh(definition, current_tag)
