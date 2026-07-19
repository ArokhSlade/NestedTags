#pragma once

#include <cstdint>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/wrapped.hpp>

using namespace godot;

namespace NestedTags {

using id = uint32_t;

class NestedTagsDefinition : public Resource {
	GDCLASS(NestedTagsDefinition, Resource)

public:
	NestedTagsDefinition()
	: names(), parents() {
	}
	~NestedTagsDefinition() override = default;

protected:
	static void _bind_methods();
	String _to_string() const;


protected:
	Vector<StringName> names;
	Vector<id> parents;
};
}