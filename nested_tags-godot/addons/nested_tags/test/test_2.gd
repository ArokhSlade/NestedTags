extends Node

@export var num = 1.23
@export var definition : NestedTagsDefinition


func _ready():
	test_class_db()


func test_class_db():
	var tags = Tags.new()
	var methods = tags.get_method_list()
	print(methods)
	pass
	
