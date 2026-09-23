@tool extends Tree

var states = {
	DefaultState.id() : DefaultState.new(),
}
var state : State = states[DefaultState.id()]

var dict = {}

func _init():
	for _state in states:
		states[_state].owner = self


func set_tag(tag : NestedTag):
	var item = dict[tag]
	if not item:
		return
	item.set_checked(0, true)


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
func refresh(definition : NestedTagsDefinition):
	clear_all()
	
	select_mode = SelectMode.SELECT_MULTI
	hide_root = true
	columns = 1
	
	var parent_item = null
	var item
	var pending_tags = []
	
	for tag : NestedTag in definition:
		pending_tags.push_back(tag)
	var old_max = pending_tags.size()
	
	var max_item_rect = Rect2i()
	
	create_item() # invisible root()
	
	var add_tag = func(p_tag, p_parent_item):
		var _item : TreeItem = create_item(p_parent_item)
		
		# TODO: extract separate pass or strategy pattern
		_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		_item.set_text(0, definition.get_name(p_tag.get_id()))
		_item.set_selectable(0, true)
		
		_item.set_editable(0, true)
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
			push_error("NestedTagsTree.refresh(): child tag without parent tag found")
			return
		old_max = max
	var new_height = compute_height()
	print(new_height)
	custom_minimum_size.y = new_height


func clear_all():
	clear()
	dict.clear()


func _on_item_selected() -> void:
	pass


func _on_item_edited():
	var item = get_edited()
	match get_edited_column():
		0:
			pass
			# TODO


func check_switch_state(old_state, new_state):
	if new_state != old_state:
		old_state._on_exit()
		new_state._on_enter()
		state = new_state


func depth(root : TreeItem):
	var depth = 0
	var cur = root
	for child in cur.get_children():
		depth = maxi(depth, depth(child))
	depth = depth + 1
	return depth


@abstract class State:
	static func id():
		return &""
	
	var owner
	
	func _init():
		print(id())
	
	
	func _on_enter():
		pass
	
	
	func _on_exit():
		pass


class DefaultState extends State:
	static func id():
		return &"Default"
