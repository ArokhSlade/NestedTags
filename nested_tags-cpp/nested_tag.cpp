#include "nested_tag.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void NestedTags::NestedTag::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("get_id"), &NestedTag::get_id);
    ClassDB::bind_method(D_METHOD("set_id", "p_id"), &NestedTag::set_id);
}