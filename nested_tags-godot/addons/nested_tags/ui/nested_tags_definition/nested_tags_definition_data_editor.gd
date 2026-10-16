@tool extends Control

# TODO: this is misleading because internals are bound to the singleton. 
# so there's no point in exposing any other instance.
@export var data : Dictionary
@onready var tree = %NestedTagsDefinitionDataTree


func set_data(p_data):
	data = p_data
	if not is_node_ready():
		await ready
	tree.refresh(data)
