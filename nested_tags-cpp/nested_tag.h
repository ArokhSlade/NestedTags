#pragma once

#include <cstdint>
#include <godot_cpp/classes/wrapped.hpp>
#include <godot_cpp/classes/ref_counted.hpp>

using namespace godot;

namespace NestedTags {

using id_t = uint32_t;

class NestedTag : public RefCounted{
    GDCLASS(NestedTag, RefCounted)

public:
    NestedTag() : id(0) {}
    NestedTag(id_t p_id) : id(p_id) {}
    ~NestedTag() = default;

    id_t get_id() const { return id; }
    void set_id(id_t p_id) { id = p_id; }

protected:
    static void _bind_methods();

private:
    id_t id;

};
}