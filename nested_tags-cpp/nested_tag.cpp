#include "nested_tag.h"
#include <godot_cpp/core/class_db.hpp>
#include "nested_tags_definition.h"

using namespace godot;
using namespace NestedTags;

Ref<NestedTag> NestedTag::get_closest_shared_ancestor(Ref<NestedTag> other) const {
    Ref<NestedTagsDefinition> definition = NestedTagsDefinition::try_get_singleton();
    id_t ancestor_id = definition->get_closest_shared_ancestor(id, other->id);
    
    Ref<NestedTag> ret_val = definition->get_tag(ancestor_id);
    return ret_val;
}

bool NestedTag::contains(Ref<NestedTag> other) const {
    bool ret_val = false;
    Ref<NestedTagsDefinition> definition = NestedTagsDefinition::try_get_singleton();    
    Ref<NestedTag> self = definition->get_tag(id);
    
    Ref<NestedTag> shared_anc = get_closest_shared_ancestor(other);
    ret_val = (self == shared_anc);
    
    return ret_val;
}

Ref<NestedTag> NestedTag::from_string(const String &p_tag_string)
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

bool NestedTags::NestedTag::try_reparent(Ref<NestedTag> p_parent) {
    bool ret_val = false;
    Ref<NestedTagsDefinition> singleton = NestedTagsDefinition::try_get_singleton();
    if (!singleton.is_valid()) {
        UtilityFunctions::push_error(FUNCTION_STR, ": singleton is not valid.");
        return false;
    }
    ret_val = (singleton->try_reparent(this->id, p_parent->get_id()));
    return ret_val;
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
    ClassDB::bind_method(D_METHOD("get_closest_shared_ancestor", "other"), &NestedTag::get_closest_shared_ancestor);
    ClassDB::bind_method(D_METHOD("contains", "other"), &NestedTag::contains);
    ClassDB::bind_method(D_METHOD("get_id"), &NestedTag::get_id);
    ClassDB::bind_method(D_METHOD("set_id", "p_id"), &NestedTag::set_id);
    ClassDB::bind_method(D_METHOD("get_parent"), &NestedTag::get_parent);
    ClassDB::bind_method(D_METHOD("try_reparent", "p_parent"), &NestedTag::try_reparent);
    ClassDB::bind_method(D_METHOD("get_name"), &NestedTag::get_name);
    ClassDB::bind_method(D_METHOD("set_name", "p_name"), &NestedTag::set_name);
    ClassDB::bind_method(D_METHOD("as_string", "p_definition"), &NestedTag::as_string);
    ClassDB::bind_method(D_METHOD("equals", "other"), &NestedTag::_is_equal);
    ClassDB::bind_method(D_METHOD("is_valid"), &NestedTag::is_valid);
    ClassDB::bind_method(D_METHOD("is_root"), &NestedTag::is_root);
    ClassDB::bind_static_method(StringName("NestedTag"), D_METHOD("from_string", "p_tag_string"), &NestedTag::from_string);
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

String NestedTag::as_string(const Ref<NestedTagsDefinition> &definition) const {
    String result = String("");
    Vector<StringName> parent_names = get_lineage_names(definition);
    int parent_names_size = parent_names.size();
    for (int i = 0; i < parent_names_size-1  ; i++) {
        result += parent_names[i];
        result += String(".");
    }
    if (parent_names_size > 0) {
        result += parent_names[parent_names_size - 1];
    }
    return result;
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
    p_list->push_back(PropertyInfo(Variant::INT, "id", PROPERTY_HINT_NONE, "nested_tag", PROPERTY_USAGE_DEFAULT));
    p_list->push_back(PropertyInfo(Variant::STRING_NAME, "name", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL));
    p_list->push_back(PropertyInfo(Variant::INT, "parent", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_INTERNAL));
}

Vector<StringName> NestedTag::get_lineage_names(const Ref<NestedTagsDefinition> &definition) const {
    Vector<StringName> parent_names;
    id_t current_id = id;
    while (current_id != 0) {
        parent_names.push_back(definition->get_name(current_id));
        current_id = definition->get_parent_id(current_id);
    }
    parent_names.reverse(); // Reverse the order to have the root parent first
    return parent_names;
}

bool NestedTag::parse_tag(const String &p_tag_string, Ref<NestedTag> &p_result_tag) {
    bool ret_val = true;
    auto definition = NestedTagsDefinition::try_get_singleton();
    p_result_tag = definition->get_tag(0);
    
    PackedStringArray strings = p_tag_string.split(String("."));
    id_t last_tag_id = 0;
    for (String& string : strings) {
        p_result_tag = definition->get_child_tag_by_name(string, last_tag_id);
        last_tag_id = p_result_tag->get_id(); 
        if (last_tag_id == 0) {
            ret_val = false;
            break;
        }
    }
    return ret_val;
}