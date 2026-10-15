@tool
extends Node2D

@export var definition : NestedTagsDefinition = preload("uid://p5hnqnysccvd")

#@export_custom(PROPERTY_HINT_NONE, "nested_tag") 
var tag : int = 3
@export_tool_button("print tag", "Anchor") var refresh_button = print_tag

func _ready():
	print_tag()


func print_tag():
	if not definition:
		return
	
	var tag_name = definition.get_full_name(tag)
	
	print("tag: %s" % [tag_name])
	
