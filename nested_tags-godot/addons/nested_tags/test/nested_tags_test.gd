extends Node2D


@export_custom(PROPERTY_HINT_NONE, "nested_tag") var nested : int = 0

func _ready():
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
	var tag_1 = NestedTag.make("creature.animal.badger")
	var tag_2 = NestedTag.make("creature.animal.bird")
	var tag_3 = NestedTag.make("creature.animal")
	var common_ancestor = tag_1.get_closest_shared_ancestor(tag_2)
	var equals = tag_1.equals(tag_2)
	var is_contained = tag_2.is_contained_in(tag_3)
	var contains = tag_3.contains(tag_2)
	pass
	return
