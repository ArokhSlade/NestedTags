#pragma once

#include <cstdint>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/classes/wrapped.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/vector.hpp>
#include "nested_tag_id.h"

using namespace godot;

namespace NestedTags {
    
class NestedTagsDefinition;

class NestedTag : public RefCounted {
    GDCLASS(NestedTag, RefCounted)
    
private:
    id_t id;

public:
    // TODO: protect users from trying to call constructors directly. tags are not supposed to be real objects to begin with. just ints that live somewhere
    NestedTag() : id(0) {}
    NestedTag(id_t p_id) : id(p_id) {}
    ~NestedTag() = default;

    id_t get_id() const;
    void set_id(id_t p_id);
    Ref<NestedTag> get_parent() const;
    void set_parent(Ref<NestedTag> p_parent);
    StringName get_name() const;
    void set_name(const StringName &p_name);

    bool is_root() const;
    bool is_valid() const;

    bool operator==(const NestedTag &other) const { return id == other.id; }

protected:
    static void _bind_methods();    
    bool _is_equal(const Variant &p_other) const;
    
    bool _get(const StringName &p_name, Variant &r_ret) const;
    void _get_property_list(List<PropertyInfo> *p_list) const;
    String _to_string() const;

    /** list names of ancestors follwed by own name. */
    Vector<StringName> get_lineage_names() const;
};
}