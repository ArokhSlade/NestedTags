@tool
extends PanelContainer

signal tag_selected(id)

func refresh_tree(definition):
	$NestedTagSelectorTree.refresh(definition)


func set_tag(tag):
	$NestedTagSelectorTree.set_tag(tag)


func _on_nested_tag_selector_tree_tag_checked(tag):
	tag_selected.emit(tag)
