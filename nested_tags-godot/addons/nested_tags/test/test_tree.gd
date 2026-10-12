extends Tree

func _iter_init(iter):
	iter[0] = get_root()
	return null != iter[0]


func _iter_next(iter):
	iter[0] = iter[0].get_next_in_tree()
	return null != iter[0]


func _iter_get(iter):
	return iter


func _ready() -> void:
	create_item()
	for item in self:
		print("hello ", item)


func _process(delta: float) -> void:
	pass
