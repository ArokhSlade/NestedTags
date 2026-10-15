@tool extends "res://addons/nested_tags/utility/iter_tree.gd"

signal tag_checked(tag)

const COLUMN_CHECK = 0

var items_and_tags = {}

func set_checked(tag : int):
	var item = items_and_tags.get(tag)
	if not item:
		push_error("NestedTagTree::set_tag(%s): tag not found." % [tag])
		return
	update_checks(item)


func get_checked():
	var item = find_checked_recursive(get_root())
	var tag = items_and_tags[item]
	return tag


func find_checked_recursive(item):
	var checked = item
	for child in item.get_children():
		if child.is_checked(COLUMN_CHECK):
			checked = find_checked_recursive(child)
			if not checked:
				checked = child
			break
	return checked


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


## constructs tree from tags. caches those "pending" tags whose parents it hasn't seen yet
func refresh(definition : NestedTagsDefinition, checked_tag : int):
	clear_all()
	
	select_mode = SelectMode.SELECT_MULTI
	hide_root = true
	columns = 1
	
	var parent_item = null
	var item
	var pending_tags = []
	
	for tag : int in definition:
		pending_tags.push_back(tag)
	var old_max = pending_tags.size()
	
	var max_item_rect = Rect2i()
	
	var root = create_item() # invisible root()
	var null_tag : int = (0)
	root.set_text(0, definition.get_name(null_tag)) # TODO: let definitions have names? show name as root item?
	root.set_editable(0, false)
	items_and_tags[root] = null_tag
	items_and_tags[null_tag] = root
	
	var add_tag = func(p_tag, p_parent_item):
		var _item : TreeItem = create_item(p_parent_item)
		
		_item.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		_item.set_text(0, definition.get_name(p_tag))
		_item.set_selectable(0, true)
		
		_item.set_editable(0, true)
		items_and_tags[p_tag] = _item
		items_and_tags[_item] = p_tag
		
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
			elif items_and_tags.has(parent_tag):
				parent_item = items_and_tags[parent_tag]
				max = max - 1
				pending_tags[i] = pending_tags[max]
				add_tag.call(tag, parent_item)
			else:
				pass # continue with pending_tags
			
			i += 1
		
		if max == old_max:
			push_error("NestedTagTree.refresh(): child tag without parent tag found")
			return
		old_max = max
	var new_height = compute_height()
	custom_minimum_size.y = new_height
	
	if null == checked_tag:
		push_error("nested_tag_tree::refresh(): checked tag was null")
		checked_tag = items_and_tags[get_root()]
	var checked_item = items_and_tags[checked_tag]
	update_checks(checked_item)


func clear_all():
	clear()
	items_and_tags.clear()


func _on_item_selected() -> void:
	pass


func _on_item_edited():
	var item = get_edited()
	match get_edited_column():
		COLUMN_CHECK:
			update_checks(item)
		_:
			push_error("NestedTagsTest::_on_item_edited(): unexpected column edited: %s" % [get_edited_column()])


func update_checks(item):
	clear_checks()
	check_tags_up_to_root(item)
	tag_checked.emit(items_and_tags[item])


func clear_checks():
	for item in self:
		item.set_checked(COLUMN_CHECK, false)


func check_tags_up_to_root(item):
	while get_root() != item and null != item:
		item.set_checked(COLUMN_CHECK, true)
		item = item.get_parent()


func depth(root : TreeItem):
	var depth = 0
	var cur = root
	for child in cur.get_children():
		depth = maxi(depth, depth(child))
	depth = depth + 1
	return depth
