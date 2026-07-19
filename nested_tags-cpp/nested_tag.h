#pragma once

#include <cstdint>
#include <godot_cpp/classes/wrapped.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include "nested_tag_id.h"
#include "nested_tags_definition.h"

using namespace godot;

namespace NestedTags {
    
class NestedTagsDefinition;

class NestedTag : public RefCounted{
    GDCLASS(NestedTag, RefCounted)
    friend NestedTagsDefinition::NestedTagsDefinition();
    
private:
    id_t id;

public:
    NestedTag() : id(0) {}
    NestedTag(id_t p_id) : id(p_id) {}
    ~NestedTag() = default;

    id_t get_id() const { return id; }
    void set_id(id_t p_id) { id = p_id; }

    bool operator==(const NestedTag &other) const { return id == other.id; }

protected:
    static void _bind_methods();    
    bool _is_equal(const Variant &p_other) const;
    bool _is_valid() const;

protected: 
    static NestedTagsDefinition* nested_tags_definition;
};
}