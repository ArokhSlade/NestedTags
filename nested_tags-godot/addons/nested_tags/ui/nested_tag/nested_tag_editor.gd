@tool
extends PanelContainer

signal tag_selected(id)

func refresh(definition, tag):
	%NestedTagTree.refresh(definition, tag)
	refresh_button(definition, tag)


func refresh_button(definition : NestedTagsDefinition, tag):
	var full_name = definition.get_full_name(tag)
	$ExpandButton.text = full_name


func _on_nested_tag_tree_tag_checked(tag):
	tag_selected.emit(tag)


func _on_expand_button_pressed():
	$ExpandButton.hide()
	$TreeView.show()


func _on_minimize_button_pressed():
	$TreeView.hide()
	$ExpandButton.show()
