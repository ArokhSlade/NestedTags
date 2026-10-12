@tool
extends Node2D


@export_custom(PROPERTY_HINT_NONE, "nested_tag") var nested : int = 3 :
	set(value):
		print("tag changed: %s" % [value])
		nested = value
@export_tool_button("print tag", "Anchor") var refresh_button = print_tag
@onready var tag : NestedTag = NestedTagsDefinition.try_get_singleton().get_tag(0)


func print_tag():
	print("tag: %s" % [nested])
	

func _ready():
	test_match()

func test_basics():
	var def = NestedTagsDefinition.try_get_singleton()
	if null == def:
		return
	
	print("nested tags test::_ready(): ", str(def))
	def.add("hello", 0)
	def.add("world", 1) 
	
	var tag = def.get_tag(1)
	print(tag)
	print("hello: ", tag.is_valid())
	var tag_2 = def.get_tag(2)
	print(tag_2)
	print(tag_2.equals(tag))
	tag_2.set_id(tag.get_id())
	print(tag_2.equals(tag))
	print("tag is valid? ", tag_2.is_valid())
	tag_2.set_id(0)
	print("tag is valid? ", tag_2.is_valid())
	nested = tag.get_id()


func test_match():
	var tag_1 = NestedTag.from_string("creature.animal.badger")
	print(tag_1.get_name())
	var tag_2 = NestedTag.from_string("creature.animal.bird")
	var tag_3 = NestedTag.from_string("creature.animal")
	var common_ancestor = tag_1.get_closest_shared_ancestor(tag_2)
	var equals_not = tag_1.equals(tag_2)
	var equals = tag_1.equals(tag_1)
	var not_contains = tag_2.contains(tag_3)
	var contains = tag_3.contains(tag_2)
	pass
	return
