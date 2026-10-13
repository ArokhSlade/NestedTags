@tool
extends PanelContainer

signal tag_selected(id)

func refresh_tree(definition):
	$NestedTagTree.refresh(definition)


func set_tag(tag):
	$NestedTagTree.set_tag(tag)


func _on_nested_tag__tree_tag_checked(tag):
	tag_selected.emit(tag)
