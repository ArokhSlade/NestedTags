extends Node2D


func _ready():
	var def = NestedTagsDefinition.new()
	print(str(def))
	var tag = NestedTag.new()
	tag.set_id(12)
	print("tag id: ", tag.get_id())
