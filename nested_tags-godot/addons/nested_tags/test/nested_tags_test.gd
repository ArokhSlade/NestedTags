extends Node2D


func _ready():
	var def = NestedTagsDefinition.new()
	print(str(def))
	var tag = NestedTag.new()
	tag.set_id(12)
	print("tag id: ", tag.get_id())
	var tag_2 = NestedTag.new()
	tag.set_id(1)
	print(tag_2.equals(tag))
	tag_2.set_id(tag.get_id())
	print(tag_2.equals(tag))
