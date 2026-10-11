@tool
extends PanelContainer


func refresh_tree(definition):
	$NestedTagSelectorTree.refresh(definition)


func set_tag(tag):
	$NestedTagSelectorTree.set_tag(tag)
