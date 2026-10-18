extends Node

@export var num = 1.23
@export var definition : NestedTagsDefinition


func _ready():
	test_trim()


func test_class_db():
	var tags = Tags.new()
	var methods = tags.get_method_list()
	print(methods)
	pass


func test_trim():
	var string = "123abc"
	var trimmed = string.trim_suffix("c")
	print(trimmed)
	string = "123abc\""
	print(string)
	trimmed = string.trim_suffix("\"")
	print(trimmed)
