extends Node
class_name Tags

static var definition : NestedTagsDefinition

static var _singleton

static func _static_init():
	var definition_path = ProjectSettings.get_setting("nested_tags/nested_tags_definition")
	definition = load(definition_path)
	print("definition loaded from ", definition_path)


static func get_singleton():
	if not _singleton:
		_singleton = Tags.new()
	return _singleton


static func tag(tag_full_name):
	ensure_definition()
	return definition.get_tag(tag_full_name)

 
static func both(tag, other_tag):
	if tag is String or tag is StringName:
		tag = definition.get_tag(tag)
	if other_tag is String or other_tag is StringName:
		other_tag = definition.get_tag(other_tag)
	return definition.match(tag, other_tag)


static func owns(tag, other_tag):
	if tag is String or tag is StringName:
		tag = definition.get_tag(tag)
	if other_tag is String or other_tag is StringName:
		other_tag = definition.get_tag(other_tag)
	return definition.contains(tag, other_tag)


static func name(tag):
	if tag is String or tag is StringName:
		tag = definition.get_tag(tag)
	return definition.get_name(tag)


static func full_name(tag):
	if tag is String or tag is StringName:
		tag = definition.get_tag(tag)
	return definition.get_full_name(tag)


static func add(tag_name, tag_parent):
	return definition.add_tag(tag_name, tag_parent)


static func reparent_tag(tag, new_parent):
	if tag is String or tag is StringName:
		tag = definition.get_tag(tag)
	if new_parent is String or new_parent is StringName:
		new_parent = definition.get_tag(new_parent)
	definition.try_reparent(tag, new_parent)


static func rename(tag, new_name):
	if tag is String or tag is StringName:
		tag = definition.get_tag(tag)
	definition.try_rename(tag, new_name)


static func remove(tag): 
	if tag is String or tag is StringName:
		tag = definition.get_tag(tag)
	definition.erase(tag)


static func names(tag):
	if tag is String or tag is StringName:
		tag = definition.get_tag(tag)
	return definition.get_names(tag)


static func get_child_tags(parent_tag):
	ensure_definition()
	if parent_tag is String or parent_tag is StringName:
		parent_tag = definition.get_tag(parent_tag)
	var tags = []
	for tag in definition:
		if definition.get_parent_id(tag) == parent_tag:
			tags.push_back(tag)
	return tags


static func get_descendant_tags(parent_tag):
	ensure_definition()
	if parent_tag is String or parent_tag is StringName:
		parent_tag = definition.get_tag(parent_tag)
	
	var ret_val = []
	var pending = []
	var dismissed = []
	
	for tag in definition:
		if tag == parent_tag:
			dismissed.push_back(tag)
		elif definition.get_parent_id(tag) == parent_tag:
			ret_val.push_back(tag)
		else:
			pending.push_back(tag)
	
	var finished = false
	while not finished:
		finished = true
		for i in range(pending.size()):
			var tag = pending[i]
			if tag == 0:
				continue
			elif definition.get_parent_id(tag) in ret_val:
				ret_val.push_back(tag)
			elif definition.get_parent_id(tag) in dismissed:
				dismissed.push_back(tag)
			finished = false
			pending[i] = 0
	
	return ret_val


static func has_tag(tag):
	ensure_definition()
	if tag is String or tag is StringName:
		if tag.is_empty():
			return false
		# TODO: this is a workaround for logical inconsistency:
		#		has_tag(get_tag("nonsense")) will return true.
		#		because get_tag("nonsense") == 0 currently
		elif tag == NestedTagsDefinition.get_null_tag_name():
			tag = 0
		else:
			print("hello: ", tag)
			tag = definition.get_tag(tag)
			if tag == 0: 
				return false
	var ret_val = definition.has_tag(tag)
	return ret_val


static func ensure_definition():
	if not definition:
		_static_init()


func get_method_list() -> Array[Dictionary]:
	var ret_val = super()
	var tag_param_names = ["tag", "other_tag", "parent_tag", "tag_full_name"]
	for method in ret_val:
		for arg in method.args:
			if arg.name in tag_param_names:
				arg.hint_string = "nested_tag"
	return ret_val
