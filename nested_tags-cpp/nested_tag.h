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

    bool operator==(const NestedTag &other) const { return id == other.id; }

protected:
    static void _bind_methods();    
    bool _is_equal(const Variant &p_other) const;
    bool _is_valid() const;
    String _to_string() const;

    Vector<StringName> get_parent_names() const;
};
}