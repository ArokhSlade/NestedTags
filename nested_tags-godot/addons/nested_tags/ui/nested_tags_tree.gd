@tool extends Tree

signal add_tag_requested(name, parent_id)
signal rename_tag_requested(tag_id, new_name)

const Manipulator = preload("uid://crrr3lkwp4tpe")

var states = {
	DefaultState.id() : DefaultState.new(),
	AddingTag.id() : AddingTag.new()
}
var state : State = states[DefaultState.id()]

var dict = {}

var manipulated_item
var manipulated_column


func _init():
	for _state in states:
		states[_state].owner = self


## constructs tree from tags. caches those "pending" tags whose parents it hasn't seen yet
func refresh(definition : NestedTagsDefinition):
	clear_all()
	hide_root = true
	var parent = null
	var item
	var pending_tags = []
	
	for tag : NestedTag in definition:
		pending_tags.push_back(tag)
	var old_max = pending_tags.size()
	
	var add_tag = func(p_tag, p_parent):
		var _item = create_item(p_parent)
		_item.set_text(0, definition.get_name(p_tag.get_id()))
		dict[p_tag] = _item
		dict[_item] = p_tag
	
	while old_max > 0:
		var i = 0
		var max = old_max
		
		while i < max:
			var tag = pending_tags[i]
			
			if tag.is_root():
				parent = null
				max = max-1
				pending_tags[i] = pending_tags[max]
				add_tag.call(tag, get_root())
			elif dict.has(tag.get_parent()):
				parent = dict[tag.get_parent()]
				max = max-1
				pending_tags[i] = pending_tags[max]
				add_tag.call(tag, parent)
			else:
				pass
			i += 1
		
		if max == old_max:
			push_error("NestedTagsTree.refresh(): child tag without parent tag found")
			return
		old_max = max


func clear_all():
	clear()
	dict.clear()


func request_add_tag(name):
	var item = manipulated_item
	if null == item:
		push_error("invalid item position?")
		return
	var parent_tag : NestedTag = dict[item]
	add_tag_requested.emit(name, parent_tag.get_id())


func _gui_input(event):
	if event.global_position != %Manipulator.global_position:
		if get_item_at_position(get_local_mouse_position()):
			%Manipulator.hide()
			%PopupTimer.start()
			%Manipulator.global_position = event.global_position


func _on_item_edited():
	var new_name = get_edited().get_text(get_edited_column())
	var tag = dict[get_edited()]
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
