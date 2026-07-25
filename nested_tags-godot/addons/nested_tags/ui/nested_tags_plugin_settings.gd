@tool extends Control
var object

@export var resource : NestedTagsDefinition

func _ready():
	show_resource_edit()


func show_resource_edit():
	var obj_id = self.get_instance_id()
	
	var resource_picker = EditorInterface.get_inspector().instantiate_property_editor(
		self, 
		TYPE_OBJECT, 
		"resource", 
		PROPERTY_HINT_RESOURCE_TYPE, 
		"NestedTagsDefinition", 
		PROPERTY_USAGE_DEFAULT
	)
	
	resource_picker.label = resource_picker.name
	resource_picker.set_object_and_property(self, "resource")
	
	resource_picker.property_changed.connect(
		func(property, value, field, changing):
			self.set(property, value)
	)
	
	%UIParent.add_child(resource_picker)
	resource_picker.update_property() 
