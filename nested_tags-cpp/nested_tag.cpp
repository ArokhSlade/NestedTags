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
    String result = String("(");
    Vector<StringName> parent_names = get_parent_names();
    int parent_names_size = parent_names.size();
    for (int i = 0; i < parent_names_size-1  ; i++) {
        result += parent_names[i];
        result += String(" -> ");
    }
    if (parent_names_size > 0) {
        result += parent_names[parent_names_size - 1];
    }
    result += String(")");
    return result;
}

Vector<StringName> NestedTag::get_parent_names() const
{
    Vector<StringName> parent_names;
    Ref<NestedTagsDefinition> singleton = NestedTagsDefinition::get_singleton();
    id_t current_id = id;
    while (current_id != 0) {
        parent_names.push_back(singleton->get_name(current_id));
        current_id = singleton->get_parent_id(current_id);
        parent_names.reverse(); // Reverse the order to have the root parent first
    }
    return parent_names;
}
