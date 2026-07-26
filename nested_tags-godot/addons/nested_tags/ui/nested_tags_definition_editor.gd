@tool extends Control

@export var definition : NestedTagsDefinition

func set_definition(p_definition):
	definition = p_definition
	clear()
	populate()


func clear():
	pass


func populate():
	if null == definition:
		return
	for tag in definition:
		print(str(tag))


func _ready():
	populate()
