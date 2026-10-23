@tool extends "res://addons/nested_tags/ui/nested_tags_tree_base.gd"

signal tag_checked(tag)

const COLUMN_CHECK = 0

func get_checked():
	var item = _find_checked_recursive(get_root())
	var tag = items_to_tags[item]
	return tag


func set_checked(tag : int):
	var item = tags_to_items.get(tag)
	if not item:
		push_error("NestedTagTree::set_tag(%s): tag not found." % [tag])
		return
	_update_checks(item)


## constructs tree from tags. caches those "pending" tags whose parents it hasn't seen yet
func refresh(definition : NestedTagsDefinition, checked_tag : int):
	var tags = _tags_from_definition(definition)
	
	_refresh(tags)
	
	if null == checked_tag:
		push_warning("nested_tag_tree::refresh(): checked tag was null. using null tag instead.")
		checked_tag = items_to_tags[get_root()]
	var checked_item = tags_to_items[checked_tag]
	
	_update_checks(checked_item)


func _add_tag(p_tag, p_parent_item, p_tag_name):
	var _item = super(p_tag, p_parent_item, p_tag_name)
	_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	_item.set_text(0, p_tag_name)
	_item.set_selectable(0, true)
	_item.set_editable(0, true)
	return _item


func _tags_from_definition(definition):
	var tags = {}
	tags[0] = {
		name = definition.get_name(0),
		parent = definition.get_parent_id(0)
	}
	for tag in definition:
		tags[tag] = {
			name = definition.get_name(tag),
			parent = definition.get_parent_id(tag)
		}
	return tags


func _find_checked_recursive(item):
	var checked = item
	for child in item.get_children():
		if child.is_checked(COLUMN_CHECK):
			checked = _find_checked_recursive(child)
			if not checked:
				checked = child
			break
	return checked


func _update_checks(item):
	_clear_checks()
	_check_tags_up_to_root(item)
	tag_checked.emit(items_to_tags[item])


func _clear_checks():
	for item in self:
		item.set_checked(COLUMN_CHECK, false)


func _check_tags_up_to_root(item):
	while get_root() != item and null != item:
		item.set_checked(COLUMN_CHECK, true)
		item = item.get_parent()


func _on_item_selected() -> void:
	pass


func _on_item_edited():
	var item = get_edited()
	match get_edited_column():
		COLUMN_CHECK:
			_update_checks(item)
		_:
			push_error("NestedTagsTest::_on_item_edited(): unexpected column edited: %s" % [get_edited_column()])
