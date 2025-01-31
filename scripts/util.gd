extends Node

func load_all_resources_in_dir(path) -> Array[Resource]:
	var dir_access = DirAccess.open(path)
	var resources: Array[Resource]
	if dir_access:
		var files = dir_access.get_files()
		for file in files:
			if file.ends_with(".tres"):
				var file_path = path + file
				var resource = load(file_path)
				if resource:
					resources.append(resource)
				else:
					printerr("Failed to load resource:", file)
	else:
		printerr("Failed to open directory")
	return resources
