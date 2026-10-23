@tool extends Control

@export var data : Dictionary
@onready var tree = %NestedTagsDefinitionDataTree


func set_data(p_data):
	data = p_data
	if not is_node_ready():
		await ready
	tree.refresh(data)
