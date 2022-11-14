extends Node

func delete_directory(dir_path):
	
	var dir = Directory.new()
	if dir.open(dir_path) != OK:
		printerr("Error deleting directory, unable to open path:", dir_path)
		return false
	
	# recursively delete all files from this path
	if !delete_files_in_dir(dir_path, false): return false
	
	# delete directory
	if dir.remove(dir_path) != OK:
		return false
	
	return true
	
	

func delete_files_in_dir(dir_path, delete_self = true):
	var dir = Directory.new()
	var file_name
	var dirs = []
	var files = []
	
	if dir.open(dir_path) != OK:
		printerr("Error deleting files in directory, unable to open path:", dir_path)
		return false
	dir.list_dir_begin(true)
	file_name = dir.get_next()
	
	# collect lists of files and folders
	while file_name != "":
		var filepath = str(dir_path, "/", file_name)
		# if current file is a directory, add to directory list
		if dir.current_is_dir():
			dirs.append(filepath)
		# otherwise add file to files list for deletion
		else:
			files.append(filepath)
		file_name = dir.get_next()
	
	# delete files
	for file in files:
		if dir.remove(file) != OK:
			printerr("Error deleting file ", file)
			return false
		else:
			print("Deleting file ", file)
	
	# recursively delete directories
	for new_dir in dirs:
		if !delete_files_in_dir(new_dir): return false
	
	# if there are no directories, delete self
	if delete_self:
		if dir.remove(dir_path) != OK:
			printerr("Error deleting directory ", dir_path)
			return false
		else:
			print("Deleting directory ", dir_path)
	
	return true
