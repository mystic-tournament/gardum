class_name Utils


static func truncate_and_free(array: Array, size: int) -> void:
	assert(array.size() >= size, "Specified size of the array should be bigger or equal than truncation size")
	for _i in range(size, array.size()):
		array.pop_back().free()


# TODO 4.0: Return Variant type
static func get_scene_property(state: SceneState, node_idx: int, property: String):
	for i in state.get_node_property_count(node_idx):
		if state.get_node_property_name(node_idx, i) == property:
			return state.get_node_property_value(node_idx, i)


static func get_script_icon(script: Script) -> String:
	for class_script in ProjectSettings.get_setting("_global_script_classes"):
		if class_script.path == script.resource_path:
			return ProjectSettings.get_setting("_global_script_class_icons")[class_script.class]
	return String()
