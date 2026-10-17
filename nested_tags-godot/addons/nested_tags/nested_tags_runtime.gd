@abstract
extends Node
class_name Tags

static var definition : NestedTagsDefinition

static func _static_init():
	var definition_path = ProjectSettings.get_setting("nested_tags/nested_tags_definition")
	definition = load(definition_path)


static func tag(tag_full_name):
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
