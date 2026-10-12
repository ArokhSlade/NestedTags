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
	add_tag(text_edit.text)


func add_tag(name, parent_id = 0):
	definition.add(name, parent_id)
	tree.refresh(definition)


func erase_tag(tag_id):
	definition.erase(tag_id)
	tree.refresh(definition)


func rename_tag(tag_id, new_name):
	definition.rename(tag_id, new_name)
	tree.refresh(definition)


func reparent_tag(tag_id, new_parent_id):
	var tag = definition.get_tag(tag_id)
	var parent_tag = definition.get_tag(new_parent_id)
	print("hello ", tag.get_closest_shared_ancestor(parent_tag).as_string(definition))
	if tag.get_closest_shared_ancestor(parent_tag) == tag:
		push_warning("Cannot reparent tag to its own descendent.")
		return
	definition.reparent(tag_id, new_parent_id)
	tree.refresh(definition)


func _on_refresh_button_pressed():
	tree.refresh(definition)


func _on_nested_tags_definition_tree_add_tag_requested(tag_name, parent_id):
	add_tag(tag_name, parent_id)


func _on_nested_tags_definition_tree_erase_tag_requested(tag_id):
	erase_tag(tag_id)

func _on_nested_tags_definition_tree_rename_tag_requested(tag_id, new_name):
	rename_tag(tag_id, new_name)


func _on_nested_tags_definition_tree_reparent_tag_requested(tag_id, new_parent_id):
	reparent_tag(tag_id, new_parent_id)


func _gui_input(event):
	var mouse = {"global_position" : get_global_mouse_position()}
	%Label.text = str(get_window().position)
	%Label2.text = str(mouse.global_position)
	%Label3.text = str(get_screen_position())


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
