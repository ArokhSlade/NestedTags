@tool extends Tree

signal add_tag_requested(name, parent_id)
signal rename_tag_requested(tag_id, new_name)
signal erase_tag_requested(tag_id)
signal reparent_tag_requested(tag_id, new_parent_id)

const Manipulator = preload("uid://crrr3lkwp4tpe")
const TREE_ITEM_WIDGET = preload("uid://cf6gquhp4lyak")
const BUTTON_ERASE = 1
const BUTTON_ADD = 2

var dict = {}
var last_hovered_item


## constructs tree from tags. temporarily caches those "pending" tags whose parents it hasn't seen yet
func refresh(definition : NestedTagsDefinition):
	print("nested_tags_definition_tree::refresh(): start!")
	clear_all()
	
	select_mode = SelectMode.SELECT_MULTI
	hide_root = true
	columns = 3
	enable_drag_unfolding = true
	
	if not definition:
		return
	
	var parent_item = null
	var item
	var pending_tags = []
	
	for tag : NestedTag in definition:
		print("nested_tags_definition_tree::refresh(): tag: ", tag.as_string(definition))
		pending_tags.push_back(tag)
	var old_max = pending_tags.size()
	
	var max_item_rect = Rect2i()
	
	create_item() # invisible root()
	
	var add_tag = func(p_tag, p_parent_item):
		var _item : TreeItem = create_item(p_parent_item)
		
		_item.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		_item.set_cell_mode(2, TreeItem.CELL_MODE_CUSTOM)
		_item.set_text(0, definition.get_name(p_tag.get_id()))
		_item.set_selectable(0, true)
		
		_item.set_editable(0, true)
		_item.set_editable(1, true)
		_item.set_editable(2, true)
		dict[p_tag] = _item
		dict[_item] = p_tag
		
		max_item_rect.position = max_item_rect.position.min(get_item_area_rect(_item).position)
		max_item_rect.size = max_item_rect.size.min(get_item_area_rect(_item).size)
	
	while old_max > 0:
		var i = 0
		var max = old_max
		
		while i < max:
			var tag = pending_tags[i]
			
			var tag_id = tag.get_id()
			var parent_id = definition.get_parent_id(tag_id)
			var parent_tag = definition.get_tag(parent_id)
			
			if definition.is_root_tag(tag_id):
				parent_item = null
				max = max - 1
				pending_tags[i] = pending_tags[max]
				add_tag.call(tag, get_root())
			elif dict.has(parent_tag):
				parent_item = dict[parent_tag]
				max = max - 1
				pending_tags[i] = pending_tags[max]
				add_tag.call(tag, parent_item)
			else:
				pass # continue with pending_tags
			
			i += 1
		
		if max == old_max:
			push_error("NestedTagsDefinitionTree.refresh(): child tag without parent tag found")
			return
		old_max = max
	var new_height = compute_height()
	print(new_height)
	custom_minimum_size.y = new_height
	#set_size(Vector2i(0, 599))


func draw_custom_tree_item(item : TreeItem, rect : Rect2i):
	var widget = item.get_metadata(0).widget
	
	widget.size = rect.size
	widget.position = rect.position
	
	print(item.get_text(0))


func clear_all():
	clear()
	dict.clear()


func _gui_input(event : InputEvent):
	if event is InputEventMouse:
		move_buttons_to_current_item()


func _on_item_selected() -> void:
	pass


func _on_item_edited():
	var item = get_edited()
	match get_edited_column():
		0:
			var new_name = item.get_text(get_edited_column())
			var tag : NestedTag = dict[item]
			if tag.get_name() != new_name:
				rename_tag_requested.emit(tag.get_id(), new_name) 


func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	match id:
		BUTTON_ERASE:
			var tag = dict[item]
			erase_tag_requested.emit(tag.get_id())
		BUTTON_ADD:
			$TagAdder.open()


func _on_tag_adder_text_submitted(new_text):
	request_add_tag(last_hovered_item, new_text)
	$TagAdder.close()


func request_add_tag(item, name):
	if null == item:
		push_error("request_add_tag(%s): invalid item position?" % [name])
		return
	var parent_tag : NestedTag = dict[item]
	add_tag_requested.emit(name, parent_tag.get_id())


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
	var icon = theme.get_icon("Eraser", "EditorIcons")
	item.add_button(0, icon, BUTTON_ERASE, false, "Erase this tag.", "Erase this tag. Will not mess up other tags, but any variables with this value will cause errors.")
	icon = theme.get_icon("ToolAddNode", "EditorIcons")
	item.add_button(0, icon, BUTTON_ADD, false, "Add a new tag.", "Add a new tag under this one.")


func _on_tag_adder_text_canceled(text):
	$TagAdder.close()


func _on_mouse_exited():
	if last_hovered_item:
		remove_buttons(last_hovered_item)


func _get_drag_data(at_position):
	var target_item = get_item_at_position(at_position)
	if not target_item:
		return null
	return dict[target_item]


func _can_drop_data(at_position, data):
	if not data is NestedTag:
		return false
	
	drop_mode_flags = DROP_MODE_ON_ITEM
	var drop_section = get_drop_section_at_position(at_position)
	const NO_DROP = 100
	if NO_DROP == drop_section:
		return false
	
	var target_item = get_item_at_position(at_position)
	var source_item = dict[data]
	var target_is_descendent = get_closest_shared_ancestor(source_item, target_item) == source_item
	
	return not target_is_descendent


func _drop_data(at_position, data):
	if not data is NestedTag:
		return
	var target_item = get_item_at_position(at_position)
	reparent_tag_requested.emit(data.id, dict[target_item].id)


func compute_height():
	var item = get_root().get_next_visible()
	if not item:
		return 0
	var visible_count = 1
	while item:
		visible_count += 1
		item = item.get_next_visible()
	var row_height = get_theme_constant("v_separation")
	row_height += get_theme_constant("inner_item_margin_top")
	row_height += get_theme_constant("inner_item_margin_bottom")
	row_height += get_theme_font("font").get_height(get_theme_font_size("font_size"))
	var height = row_height * visible_count
	return height


func depth(root : TreeItem):
	var depth = 0
	var cur = root
	for child in cur.get_children():
		depth = maxi(depth, depth(child))
	depth = depth + 1
	return depth


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
