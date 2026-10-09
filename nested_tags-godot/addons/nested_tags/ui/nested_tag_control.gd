@tool
extends PanelContainer


func refresh_tree(definition):
	$NestedTagsTreeUser.refresh(definition)


func set_tag(tag):
	$NestedTagsTreeUser.set_tag(tag)
