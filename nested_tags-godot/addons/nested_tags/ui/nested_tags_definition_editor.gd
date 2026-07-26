@tool extends Control

@export var definition : NestedTagsDefinition
@onready var tree = $NestedTagsTree
@onready var text_edit = %TextEdit

func set_definition(p_definition):
	definition = p_definition
	tree.refresh(definition)


func _on_button_pressed():
	definition.add(text_edit.text, 0)
	tree.refresh(definition)


func _on_refresh_button_pressed():
	tree.refresh(definition)
