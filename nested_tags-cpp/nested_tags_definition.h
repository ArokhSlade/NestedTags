#pragma once

#include "godot_cpp/classes/resource.hpp"
#include "godot_cpp/classes/wrapped.hpp"

using namespace godot;

class NestedTagsDefinition : public Resource {
	GDCLASS(NestedTagsDefinition, Resource)

protected:
	static void _bind_methods();

public:
	NestedTagsDefinition() = default;
	~NestedTagsDefinition() override = default;
};
