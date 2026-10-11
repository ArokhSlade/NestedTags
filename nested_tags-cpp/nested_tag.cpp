#include "nested_tag.h"
#include <godot_cpp/core/class_db.hpp>
#include "nested_tags_definition.h"

using namespace godot;
using namespace NestedTags;

bool parse_tag(const String &p_tag_string, Ref<NestedTag> &p_result_tag) {
    bool ret_val = false;
    auto definition = NestedTagsDefinition::try_get_singleton();
    p_result_tag = definition->get_tag(0); 
    return ret_val;
}

Ref<NestedTag> NestedTag::make(const String &p_tag_string)
{
    Ref<NestedTag> ret_val;
    bool succeess = parse_tag(p_tag_string, ret_val);
    return ret_val;
}  

id_t NestedTags::NestedTag::get_id() const {
    return id;
}

void NestedTags::NestedTag::set_id(id_t p_id) {
    id = p_id;
}

Ref<NestedTag> NestedTags::NestedTag::get_parent() const {
    Ref<NestedTagsDefinition> singleton = NestedTagsDefinition::try_get_singleton();
    Ref<NestedTag> parent = singleton->get_tag(singleton->get_parent_id(id));
    return parent;
}

void NestedTags::NestedTag::set_parent(Ref<NestedTag> p_parent) {
    Ref<NestedTagsDefinition> singleton = NestedTagsDefinition::try_get_singleton();
    ERR_FAIL_COND_EDMSG(!singleton.is_valid(), "NestedTag::set_parent(): singleton is not valid");
    singleton->reparent(this->id, p_parent->get_id());
}

StringName NestedTags::NestedTag::get_name() const {
    Ref<NestedTagsDefinition> singleton = NestedTagsDefinition::try_get_singleton();
    return singleton->get_name(id);
}

void NestedTags::NestedTag::set_name(const StringName &p_name) {
    Ref<NestedTagsDefinition> singleton = NestedTagsDefinition::try_get_singleton();
    ERR_FAIL_COND_EDMSG(!singleton.is_valid(), "NestedTag::set_name(): singleton is not valid");
    singleton->rename(this->id, p_name);
}

bool NestedTags::NestedTag::is_root() const
{
    return get_parent()->get_id() == 0;
}

void NestedTag::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_id"), &NestedTag::get_id);
    ClassDB::bind_method(D_METHOD("set_id", "p_id"), &NestedTag::set_id);
    ClassDB::bind_method(D_METHOD("get_parent"), &NestedTag::get_parent);
    ClassDB::bind_method(D_METHOD("set_parent", "p_parent"), &NestedTag::set_parent);
    ClassDB::bind_method(D_METHOD("get_name"), &NestedTag::get_name);
    ClassDB::bind_method(D_METHOD("set_name", "p_name"), &NestedTag::set_name);
    ClassDB::bind_method(D_METHOD("equals", "other"), &NestedTag::_is_equal);
    ClassDB::bind_method(D_METHOD("is_valid"), &NestedTag::is_valid);
    ClassDB::bind_method(D_METHOD("is_root"), &NestedTag::is_root);
    ClassDB::bind_static_method(StringName("NestedTag"), D_METHOD("make", "p_tag_string"), &NestedTag::make);
}

bool NestedTag::_is_equal(const Variant &p_other) const {
    Object *obj = p_other.operator Object *();
    if (!obj) return false;

    NestedTag *other_tag = Object::cast_to<NestedTag>(obj);
    if (!other_tag) return false;

    return this->id == other_tag->id;
}

bool NestedTag::is_valid() const {
    Ref<NestedTagsDefinition> singleton = NestedTagsDefinition::try_get_singleton();
    return singleton.is_valid() && singleton->get_tag(id) == this;
}

bool NestedTag::_get(const StringName &p_name, Variant &r_ret) const
{
    if (p_name == StringName("name"))
    {
        r_ret = Variant(get_name());
    } 
    else if (p_name == StringName("id"))
    {
        r_ret = Variant(get_id());
    }
    else if (p_name == StringName("parent"))
    {
        r_ret = Variant(get_parent());
    }
    else
    {
        return false;
    }
    return true;
}

void NestedTag::_get_property_list(List<PropertyInfo> *p_list) const
{
    p_list->push_back(PropertyInfo(Variant::INT, "id", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL));
    p_list->push_back(PropertyInfo(Variant::STRING_NAME, "name", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL));
    p_list->push_back(PropertyInfo(Variant::INT, "parent", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL));
}

String NestedTag::_to_string() const {
    String result = String("(");
    Vector<StringName> parent_names = get_lineage_names();
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

Vector<StringName> NestedTag::get_lineage_names() const {
    Vector<StringName> parent_names;
    Ref<NestedTagsDefinition> singleton = NestedTagsDefinition::try_get_singleton();
    id_t current_id = id;
    while (current_id != 0) {
        parent_names.push_back(singleton->get_name(current_id));
        current_id = singleton->get_parent_id(current_id);
    }
    parent_names.reverse(); // Reverse the order to have the root parent first
    return parent_names;
}
