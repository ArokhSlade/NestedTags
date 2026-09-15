@tool
extends Node

signal definition_loaded(definition)

var _definition : NestedTagsDefinition

func get_definition():
	return _definition


func set_definition(definition):
	_definition = definition


func load_definition(path : String):
	if path.is_empty():
		return
	
	_definition = load(path)
	if null == _definition:
		return
	
	NestedTagsDefinition.initialize_singleton(_definition)
	print(str(NestedTagsDefinition.try_get_singleton()))
	
	return _definition
