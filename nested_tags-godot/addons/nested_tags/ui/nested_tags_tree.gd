@tool extends Tree

var root : TreeItem

var dict = {}

func refresh(definition : NestedTagsDefinition):
	clear_all()
	root = create_item()
	hide_root = true
	var parent = null
	var item
	var pending = []
	
	for tag : NestedTag in definition:
		pending.push_back(tag)
	var old_max = pending.size()
	
	var add_tag = func(p_tag, p_parent):
		var _item = create_item(p_parent)
		_item.set_text(0, definition.get_name(p_tag.get_id()))
		dict[p_tag] = _item
	
	while old_max > 0:
		var i = 0
		var max = old_max
		
		while i < max:
			var tag = pending[i]
			
			if tag.is_root():
				parent = null
				max = max-1
				pending[i] = pending[max]
				add_tag.call(tag, root)
			elif dict.has(tag.get_parent()):
				parent = dict[tag.get_parent()]
				max = max-1
				pending[i] = pending[max]
				add_tag.call(tag, parent)
			else:
				pass
			i += 1
		
		if max == old_max:
			push_error("NestedTagsTree.refresh(): child tag without parent tag found")
			return
		old_max = max


func clear_all():
	clear()
	dict.clear()
