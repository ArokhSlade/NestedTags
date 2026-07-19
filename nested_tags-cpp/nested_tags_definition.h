#pragma once

#include <cstdint>
#include <godot_cpp/templates/vector.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/wrapped.hpp>
#include "nested_tag.h"

using namespace godot;

namespace NestedTags {

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
	Vector<id_t> parents;
};
}