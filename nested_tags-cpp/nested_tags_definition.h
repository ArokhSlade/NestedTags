#pragma once

#include <cstdint>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/wrapped.hpp>
#include "nested_tag_id.h"

using namespace godot;

namespace NestedTags {
	
struct TagData {
	id_t parent_id;
	StringName name;
};

class NestedTagsDefinition : public Resource {
	GDCLASS(NestedTagsDefinition, Resource)

public:
	NestedTagsDefinition();
	~NestedTagsDefinition() override = default;

	bool try_add(const StringName& p_name, id_t p_parent_id = 0);
	void erase(id_t p_id);
	void NestedTagsDefinition::_erase_recursively(id_t p_id);
	
	bool has_tag(id_t p_id) const;
	id_t try_get_id(const StringName&) const;

	bool try_reparent(id_t p_id, id_t p_parent_id);
	bool try_rename(id_t p_id, const StringName& p_name);

	StringName get_name(id_t p_id) const;
	StringName get_full_name(id_t p_tag_id) const;
	Vector<StringName> get_lineage_names(id_t p_tag_id) const;

	id_t get_parent_id(id_t p_id) const;

    Variant _iter_init(Array p__iter) const;
    Variant _iter_next(Array p__iter) const;
    Variant _iter_get(const Variant &p_iter) const;
    
    id_t try_get_child_by_name(const StringName& p_name, id_t p_parent_id) const; 
	
	int size() const;
	
	id_t get_closest_shared_ancestor(id_t p_id_1, id_t p_id_2) const;
	
protected:
	static void _bind_methods();
	String _to_string() const;
	bool _set(const StringName &p_name, const Variant &p_value);
	bool _get(const StringName &p_name, Variant &r_ret) const;
	void _get_property_list(List<PropertyInfo> *p_list) const;
	
	Array get_lineage_ids(id_t p_id) const ;
	Array get_ids() const;
	
	bool is_tag_name_valid(const String& p_name);
	bool is_name_taken_among_siblings(const String& p_name, id_t p_parent_id);
	Vector<id_t> get_child_ids(id_t p_parent_id);
	
private:
	void update_tags();
	Array get_parent_ids() const;
	Array get_names() const;
	bool _try_add_explicit(id_t p_id, const StringName &p_name, id_t p_parent_id);
	static const char* null_tag_name;

private:
	Array names;	
	Array parents;
	Array tags;
	id_t last_tag_id;
	static Ref<NestedTagsDefinition> singleton;
	
	HashMap<id_t, TagData> data;
};
}