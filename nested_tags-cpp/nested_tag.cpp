#include "nested_tag.h"
#include <godot_cpp/core/class_db.hpp>
#include "nested_tags_definition.h"

using namespace godot;
using namespace NestedTags;

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

bool NestedTag::_is_valid() const
{
    Ref<NestedTagsDefinition> singleton = NestedTagsDefinition::get_singleton();
    return singleton.is_valid() && singleton->is_id_valid(id);
}

String NestedTag::_to_string() const
{
    return String("NestedTag: ") + String::num_int64(id) + String(" (") + NestedTagsDefinition::get_singleton()->get_name(id) + String(")");
}
