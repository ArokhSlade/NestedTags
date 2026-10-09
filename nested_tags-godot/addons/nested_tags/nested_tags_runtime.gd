extends Node

var definition

func _init():
	var definition_path = ProjectSettings.get_setting("nested_tags/nested_tags_definition")
	definition = load(definition_path)
	NestedTagsDefinition.initialize_singleton(definition)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
