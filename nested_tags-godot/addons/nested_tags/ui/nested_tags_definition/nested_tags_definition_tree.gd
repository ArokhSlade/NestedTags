@tool
extends "res://addons/nested_tags/ui/nested_tags_tree_base.gd"

signal add_tag_requested(name, parent_id)
signal rename_tag_requested(tag, new_name)
signal erase_tag_requested(tag)
signal reparent_tag_requested(tag, new_parent_id)

const BUTTON_ERASE = 1
const BUTTON_ADD = 2

var last_hovered_item

## constructs tree from tags. temporarily caches those "pending" tags whose parents it hasn't seen yet
func refresh(definition_ : NestedTagsDefinition):
	var tags = _tags_from_definition(definition_)
	_refresh(tags)


func _add_tag(p_tag, p_parent_item, p_tag_name):
	var _item = super(p_tag, p_parent_item, p_tag_name)
	_item.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	_item.set_text(0, p_tag_name)
	_item.set_selectable(0, true)
	_item.set_editable(0, true)
	return _item


func _tags_from_definition(definition_):
	var tags = {
		0 : {
			name = definition_.get_null_tag_name(),
			parent = definition_.get_parent_id(0)
		}
	}
	for tag in definition_:
		tags[tag] = {
			name = definition_.get_name(tag),
			parent = definition_.get_parent_id(tag)
		}
	return tags


func draw_custom_tree_item(item : TreeItem, rect : Rect2i):
	var widget = item.get_metadata(0).widget
	
	widget.size = rect.size
	widget.position = rect.position


func _gui_input(event : InputEvent):
	if event is InputEventMouse:
		move_buttons_to_current_item()


func _on_nothing_selected():
	$TagAdder.close()


func _on_multi_selected(item, column, selected):
	$TagAdder.close()


func _on_item_edited():
	var item = get_edited()
	if item == get_root():
		return
	match get_edited_column():
		0:
			var new_name = item.get_text(get_edited_column())
			var tag : int = items_to_tags[item]
			rename_tag_requested.emit(tag, new_name) 


func deny_rename(tag, old_name):
	if not tags_to_items.has(tag):
		push_error("NestedTagsDefintionTree::deny_rename(): unknown tag")
	tags_to_items[tag].set_text(0, old_name)


func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	match id:
		BUTTON_ERASE:
			var tag = items_to_tags[item]
			erase_tag_requested.emit(tag)
		BUTTON_ADD:
			var rect := get_item_area_rect(item)
			var button_idx = item.get_button_by_id(0, BUTTON_ADD)
			var button_rect := get_item_area_rect(item, 0, button_idx)
			
			var adder_pos = button_rect.position
			adder_pos.x -= $TagAdder.size.x
			$TagAdder.position = (adder_pos)
			$TagAdder.open()


func _on_tag_adder_text_submitted(new_text):
	request_add_tag(last_hovered_item, new_text)


func feedback_invalid_input():
	$TagAdder.feedback_invalid_input()


func request_add_tag(item, name):
	if null == item:
		push_error("request_add_tag(%s): invalid item position?" % [name])
		return
	var parent_tag : int = items_to_tags[item]
	add_tag_requested.emit(name, parent_tag)


func confirm_tag_added():
	$TagAdder.close()


func move_buttons_to_current_item():
	var hovered_item = get_item_under_cursor()
	if last_hovered_item == hovered_item:
		return
	
	if last_hovered_item:
		remove_buttons(last_hovered_item)
		
	last_hovered_item = hovered_item
	if last_hovered_item:
		add_buttons(last_hovered_item)


func remove_buttons(item):
	item.clear_buttons()


func get_item_under_cursor():
	var item = get_item_at_position(get_local_mouse_position())
	return item


func  add_buttons(item):
	var theme = EditorInterface.get_editor_theme()
	var icon = theme.get_icon("ToolAddNode", "EditorIcons")
	item.add_button(0, icon, BUTTON_ADD, false, "Add a new tag.", "Add a new tag under this one.")
	
	if get_root() == item:
		return
	
	icon = theme.get_icon("Eraser", "EditorIcons")
	item.add_button(0, icon, BUTTON_ERASE, false, "Erase this tag.", "Erase this tag. Will not mess up other tags, but any variables with this value will cause errors.")


func _on_tag_adder_text_canceled(text):
	$TagAdder.close()


func _on_mouse_exited():
	if last_hovered_item:
		remove_buttons(last_hovered_item)


func _get_drag_data(at_position):
	var target_item = get_item_at_position(at_position)
	if not target_item:
		return null
	return items_to_tags[target_item]


func _can_drop_data(at_position, data):
	# TODO: filter for a more specific tupe to avoid errors
	if not data is int:
		return false
	
	drop_mode_flags = DROP_MODE_ON_ITEM
	var drop_section = get_drop_section_at_position(at_position)
	const NO_DROP = 100
	if NO_DROP == drop_section:
		return false
	
	var target_item = get_item_at_position(at_position)
	var source_item = tags_to_items[data]
	var target_is_descendent = get_closest_shared_ancestor(source_item, target_item) == source_item
	
	return not target_is_descendent


func _drop_data(at_position, data):
	if not data is int:
		return
	var target_item = get_item_at_position(at_position)
	reparent_tag_requested.emit(data, items_to_tags[target_item])


func get_closest_shared_ancestor(item_1, item_2):
	if null in [item_1, item_2]:
		return null
	
	var ret_val = get_root()
	var lineage_1 = get_lineage(item_1)
	var lineage_2 = get_lineage(item_2)
	
	var max_count = mini(lineage_1.size(), lineage_2.size())
	for i in range (max_count):
		if lineage_1[i] == lineage_2[i]:
			ret_val = lineage_1[i]
	
	return ret_val


func get_lineage(item):
	if null == item:
		return []
	var lineage = []
	while null != item:
		lineage.push_back(item)
		item = item.get_parent()
	lineage.reverse()
	return lineage
