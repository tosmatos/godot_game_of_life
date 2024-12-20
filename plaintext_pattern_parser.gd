extends Node
class_name PlaintextPatternParser

func read_file(file_path: String) -> String:
	# Check if file exists
	if not FileAccess.file_exists(file_path):
		print("File not found")
		return ""

	# Open the file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Error opening file")
		return ""

	# Read entire file as a string
	var text = file.get_as_text()

	# Close the file
	file.close()

	return text
	

func parse(file_path: String):
	var text = read_file(file_path)
	
	if text == "":
		print("Couldn't read file.")
		return
	
	var pattern = []
	var width = get_width(text)
	
	for line in text.split("\n"):
		if line.begins_with("!"): # ! are comments in plaintext gol files
			continue
		
		var pattern_line = []
		for char in line:
			if char == ".":
				pattern_line.append(0)
			elif char == "o" or char == "O":
				pattern_line.append(1)
				
		if pattern_line.size() < width: # Some (most) .cells files leave blanks after last alive cell
			for i in range (0, width - pattern_line.size()):
				pattern_line.append(0)
				
		pattern.append(pattern_line)

	return pattern

func get_width(text: String) -> int:
	var widest = 0
	
	for line in text.split("\n"):
		if line.length() > widest:
			widest = line.length() - 1
			
	return widest
