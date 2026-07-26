@tool extends Control

# TODO: this is misleading because internals are bound to the singleton. 
# so there's no point in exposing any other instance.
@export var definition : NestedTagsDefinition
@onready var tree = %NestedTagsTree
@onready var text_edit = %TextEdit

func set_definition(p_definition):
	definition = p_definition
	tree.refresh(definition)


func _on_button_pressed():
	definition.add(text_edit.text, 0)
	tree.refresh(definition)


func _on_refresh_button_pressed():
	tree.refresh(definition)
