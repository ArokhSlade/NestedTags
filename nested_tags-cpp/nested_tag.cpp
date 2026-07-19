#include "nested_tag.h"
#include <godot_cpp/core/class_db.hpp>
#include "nested_tags_definition.h"

using namespace godot;
using namespace NestedTags;

NestedTagsDefinition* NestedTag::nested_tags_definition = nullptr;

void NestedTag::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("get_id"), &NestedTag::get_id);
    ClassDB::bind_method(D_METHOD("set_id", "p_id"), &NestedTag::set_id);
    ClassDB::bind_method(D_METHOD("equals", "other"), &NestedTag::_is_equal);
    ClassDB::bind_method(D_METHOD("is_valid"), &NestedTag::_is_valid);
}

bool NestedTag::_is_equal(const Variant &p_other) const {
    Object *obj = p_other.operator Object *();
    if (!obj) return false;

    NestedTag *other_tag = Object::cast_to<NestedTag>(obj);
    if (!other_tag) return false;

    return this->id == other_tag->id;
}

bool NestedTags::NestedTag::_is_valid() const
{
    if (!nested_tags_definition) {
        return false;
    }
    return nested_tags_definition->is_id_valid(id);
}
