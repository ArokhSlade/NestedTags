extends Node2D


func _ready():
	var def = NestedTagsDefinition.get_singleton()
	print(str(def))
	def.add("hello", 0)
	def.add("world", 1)
		
	var tag = def.get_tag(1)
	print(tag)
	var tag_2 = def.get_tag(2)
	print(tag_2)
	print(tag_2.equals(tag))
	tag_2.set_id(tag.get_id())
	print(tag_2.equals(tag))
	print("tag is valid? ", tag_2.is_valid())
	tag_2.set_id(0)
	print("tag is valid? ", tag_2.is_valid())
