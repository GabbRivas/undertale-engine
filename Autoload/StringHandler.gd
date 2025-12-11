extends Node

var lang : String = "en"

@onready var string_resources : Dictionary = {
	"dialogue.test" : "res://Assets/Dialogues/test.json"
}

func get_json(resource: String) -> Dictionary:
	var path = string_resources.get(resource)
	if not FileAccess.file_exists(path): return {}
	
	var data = FileAccess.open(path, FileAccess.READ)
	var parsed_resource = JSON.parse_string(data.get_as_text())
	
	if parsed_resource is not Dictionary: return {}
	return parsed_resource.get(lang)
