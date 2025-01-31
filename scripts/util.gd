extends Node
	
func load_all_resources_in_dir(path) -> Array[Resource]:
	var dir_access = DirAccess.open(path)
	var resources: Array[Resource]
	if !dir_access:
		printerr("Failed to open directory")
		return resources
		
	var files = dir_access.get_files()
	files.sort()
	for file in files:
		if !file.ends_with(".tres"):
			continue
		var file_path = path + file
		var resource = load(file_path)
		if resource:
			resources.append(resource)
		else:
			printerr("Failed to load resource:", file)
	return resources


func seeded_shuffle(array: Array) -> void:
	for i in range(array.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp
