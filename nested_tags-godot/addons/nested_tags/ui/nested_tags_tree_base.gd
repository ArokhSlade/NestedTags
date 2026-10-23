@tool
extends "res://addons/nested_tags/utility/iter_tree.gd"

var items_to_tags = {}
var tags_to_items = {}

## constructs tree from tags. caches those "pending" tags whose parents it hasn't seen yet
func _refresh(tags):
	if not tags.has(0):
		push_error("nested_tags_tree_base::_refresh(tags): tags.has(0) was false, i.e. null tag was missing, which should always exist.")
	
	clear_all()
	
	select_mode = SelectMode.SELECT_MULTI
	hide_root = true
	columns = 1
	
	var root = create_item() # invisible root()
	root.set_text(0, tags[0].name)
	root.set_editable(0, false)
	items_to_tags[root] = 0
	tags_to_items[0] = root
	
	tags.erase(0)
	
	var pending_tags = []
	for tag in tags:
		pending_tags.push_back(tag)
	
	var old_max = pending_tags.size()
	while old_max > 0:
		var i = 0
		var max = old_max
		
		while i < max:
			var tag = pending_tags[i]
			
			var parent = tag.parent
			
			var parent_item = null
			if tags_to_items.has(parent):
				parent_item = tags_to_items[parent]
				max = max - 1
				pending_tags[i] = pending_tags[max]
				add_tag(tag, parent_item, tags[tag].name)
			
			i += 1
		
		if max == old_max:
			push_error("NestedTagTree.refresh(): child tag without parent tag found")
			return
		old_max = max
	var new_height = compute_height()
	custom_minimum_size.y = new_height


func add_tag(p_tag, p_parent_item, p_tag_name):
	var _item : TreeItem = create_item(p_parent_item)
	
	_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	_item.set_text(0, p_tag_name)
	_item.set_selectable(0, true)
	
	_item.set_editable(0, true)
	items_to_tags[_item] = p_tag
	tags_to_items[p_tag] = _item


func clear_all():
	clear()
	items_to_tags.clear()
	tags_to_items.clear()


func compute_height():
	var item = get_root().get_next_visible()
	if hide_root:
		item = item.get_next_visible()
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
	var height = row_height * (visible_count + 1)
	return height


func depth(root : TreeItem):
	var depth = 0
	var cur = root
	for child in cur.get_children():
		depth = maxi(depth, depth(child))
	depth = depth + 1
	return depth
