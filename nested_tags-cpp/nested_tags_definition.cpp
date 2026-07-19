#include "nested_tags_definition.h"
#include <godot_cpp/core/class_db.hpp>

namespace NestedTags {
void NestedTagsDefinition::_bind_methods() {
		ClassDB::bind_method(D_METHOD("_to_string"), &NestedTagsDefinition::_to_string);
}

String NestedTagsDefinition::_to_string() const
{
    return String("NestedTagsDefinition");
}
}