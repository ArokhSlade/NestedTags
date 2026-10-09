@tool
extends PanelContainer


func refresh_tree(definition):
	$NestedTagsTreeUser.refresh(definition)


func set_tag(tag : NestedTag):
	$NestedTagsTreeUser.set_tag(tag)
