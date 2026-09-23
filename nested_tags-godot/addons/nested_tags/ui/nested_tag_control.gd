@tool
extends PanelContainer

@onready var tree = $NestedTagsTreeUser

func refresh_tree(definition):
	tree.refresh(definition)


func set_tag(tag : NestedTag):
	tree.set_tag(tag)
