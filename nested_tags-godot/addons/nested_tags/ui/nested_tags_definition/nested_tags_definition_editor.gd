@tool extends Control

# TODO: this is misleading because internals are bound to the singleton. 
# so there's no point in exposing any other instance.
@export var definition : NestedTagsDefinition
@onready var tree = %NestedTagsDefinitionTree
@onready var text_edit = %TextEdit

func set_definition(p_definition):
	definition = p_definition
	if not is_node_ready():
		await ready
	tree.refresh(definition)


func _on_button_pressed():
	try_add_tag(text_edit.text)


func try_add_tag(name, parent_id = 0):
	if not definition.try_add(name, parent_id):
		return false
	else:
		tree.refresh(definition)
		return true


func erase_tag(tag_id):
	definition.erase(tag_id)
	tree.refresh(definition)


func try_rename_tag(tag_id, new_name):
	if not definition.try_rename(tag_id, new_name):
		var tag = definition.get_tag(tag_id)
		%NestedTagsDefinitionTree.deny_rename(tag)
		return false
	else:
		tree.refresh(definition)
		return true


func reparent_tag(tag_id, new_parent_id):
	var tag = definition.get_tag(tag_id)
	var parent_tag = definition.get_tag(new_parent_id)
	
	if not definition.try_reparent(tag_id, new_parent_id):
		push_warning("Cannot reparent tag to its own descendent.")
		return
	tree.refresh(definition)


func _on_refresh_button_pressed():
	tree.refresh(definition)


func _on_nested_tags_definition_tree_add_tag_requested(tag_name, parent_id):
	if not try_add_tag(tag_name, parent_id):
		%NestedTagsDefinitionTree.signal_invalid_input()
	else:
		$%NestedTagsDefinitionTree.confirm_tag_added()


func _on_nested_tags_definition_tree_erase_tag_requested(tag_id):
	erase_tag(tag_id)

func _on_nested_tags_definition_tree_rename_tag_requested(tag_id, new_name):
	try_rename_tag(tag_id, new_name)


func _on_nested_tags_definition_tree_reparent_tag_requested(tag_id, new_parent_id):
	reparent_tag(tag_id, new_parent_id)


static func is_point_inside_rect(point : Vector2, rect : Rect2):
	if point.x <= rect.position.x:
		return false
	if point.x >= rect.end.x:
		return false
	if point.y <= rect.position.y:
		return false
	if point.y >= rect.end.y:
		return false
	return true


static func polygon_from_rect(rect : Rect2):
	var points : PackedVector2Array = []
	points.push_back(rect.position)
	points.push_back(rect.position + Vector2(0, rect.size.y))
	points.push_back(rect.end)
	points.push_back(rect.position + Vector2(rect.size.x, 0))
	return points
