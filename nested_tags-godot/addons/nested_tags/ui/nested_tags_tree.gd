@tool extends Tree

signal add_tag_requested(name, parent_id)
signal rename_tag_requested(tag_id, new_name)

const Manipulator = preload("uid://crrr3lkwp4tpe")
const TREE_ITEM_WIDGET = preload("uid://cf6gquhp4lyak")
const BUTTON_ERASE = 1

var states = {
	DefaultState.id() : DefaultState.new(),
	AddingTag.id() : AddingTag.new()
}
var state : State = states[DefaultState.id()]

var dict = {}

var manipulated_item
var manipulated_column

var last_hovered_item

func _init():
	for _state in states:
		states[_state].owner = self


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
	columns = 3
	
	if not definition:
		return
	
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
			push_error("NestedTagsTree.refresh(): child tag without parent tag found")
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


func request_add_tag(name):
	var item = manipulated_item
	if null == item:
		push_error("request_add_tag(%s): invalid item position?" % [name])
		return
	var parent_tag : NestedTag = dict[item]
	add_tag_requested.emit(name, parent_tag.get_id())


func _gui_input(event : InputEvent):
	if event is InputEventMouse:
		if event.global_position != %Manipulator.global_position:
			if get_item_at_position(get_local_mouse_position()):
				%Manipulator.hide()
				%PopupTimer.start()
				%Manipulator.global_position = event.global_position
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


func _on_manipulator_add_button_pressed():
	var new_state = state._on_add_button_pressed()
	check_switch_state(state, new_state)


func _on_manipulator_text_changed(new_text):
	var new_state = state._on_name_submitted(new_text)
	check_switch_state(state, new_state)


func check_switch_state(old_state, new_state):
	if new_state != old_state:
		old_state._on_exit()
		new_state._on_enter()
		state = new_state
		update_manipulator(new_state.id())


func update_manipulator(new_state_id):
	var new_manipulator_state = \
			Manipulator.State.BUTTON if new_state_id == DefaultState.id() else\
			Manipulator.State.TEXT if 	new_state_id == AddingTag.id() else\
			Manipulator.State.NONE
	%Manipulator.switch_state(new_manipulator_state)
	
	%Manipulator.global_position = get_global_mouse_position()


func _on_popup_timer_timeout():
	manipulated_item = get_item_at_position(get_local_mouse_position())
	if manipulated_item:
		manipulated_column = get_column_at_position(get_local_mouse_position())
		%Manipulator.show()


func move_buttons_to_current_item():
	if last_hovered_item:
		remove_buttons(last_hovered_item)
	last_hovered_item = get_item_under_cursor()
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
	item.add_button(0, icon, BUTTON_ERASE, false, "Delete this tag.", "Delete this tag. Will not mess up other tags, but any variables with this value will cause errors.")
	

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
	
	
	@abstract func _on_add_button_pressed() -> State
	@abstract func _on_name_submitted(text) -> State


	func _on_enter():
		pass
	
	
	func _on_exit():
		pass


class DefaultState extends State:
	static func id():
		return &"Default"
	
	func _on_name_submitted(text):
		return self
	
	
	func _on_add_button_pressed():
		return owner.states[AddingTag.id()]


class AddingTag extends State:
	static func id():
		return &"AddingTag"
	
	
	func _on_name_submitted(name):
		owner.request_add_tag(name)
		return owner.states[DefaultState.id()]


	func _on_add_button_pressed():
		return self
