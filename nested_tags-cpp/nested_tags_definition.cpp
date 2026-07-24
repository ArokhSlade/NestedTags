#include "nested_tags_definition.h"
#include <godot_cpp/core/class_db.hpp>
#include "nested_tag.h"

namespace NestedTags {

NestedTagsDefinition::NestedTagsDefinition()
	: names(), parents() {
		NestedTag::nested_tags_definition = this;
		names.push_back(StringName(""));
		parents.push_back(0);
}

void NestedTagsDefinition::_bind_methods() {
		ClassDB::bind_method(D_METHOD("_to_string"), &NestedTagsDefinition::_to_string);
		ClassDB::bind_method(D_METHOD("is_id_valid", "p_id"), &NestedTagsDefinition::is_id_valid);
		ClassDB::bind_method(D_METHOD("add", "p_name", "p_parent_id", "p_id"), &NestedTagsDefinition::add);
}


String NestedTagsDefinition::_to_string() const
{
    return String("NestedTagsDefinition");
}
}