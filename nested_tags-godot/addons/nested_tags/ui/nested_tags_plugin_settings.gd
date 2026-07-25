@tool extends Control

var picker
var object

@export var resource := NestedTagsDefinition.new():
	set(value):
		resource = value
		# Rebuild the UI automatically whenever the object changes
		show_resource_edit()
@onready var vbox = $VBoxContainer/ScrollContainer/VBoxContainer

func _ready():
	#picker = EditorResourcePicker.new()
	#picker.base_type = "NestedTagsDefinition"
	#%PickerParent.add_child(picker)
	show_resource_edit()
	object = Node2D.new()
	add_child(object)
	$VBoxContainer/ScrollContainer.target_object = self

func show_resource_edit():
	var obj_id = self.get_instance_id()
	var editor_property: EditorProperty = EditorInterface.get_inspector().instantiate_property_editor(
		self, 
		TYPE_OBJECT, 
		"resource", 
		PROPERTY_HINT_RESOURCE_TYPE, 
		"", 
		PROPERTY_USAGE_DEFAULT
	)
	
	if editor_property:
		editor_property.label = editor_property.name
		
		# Assign the pre-calculated integer instance ID safely
		editor_property.set_object_and_property(self, "resource")
		
		# Bind synchronization logic using a bound argument to avoid lambda capture leakage
		editor_property.property_changed.connect(
			func(property, value, field, changing):
				if is_instance_valid(self):
					self.set(property, value)
		)
		
		vbox.add_child(editor_property)
		editor_property.update_property() 
