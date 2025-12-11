extends Node2D

@onready var SceneTyper = $Typer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneTyper.dialogue_file="dialogue.test"
	SceneTyper.get_json_dialogue()
	SceneTyper.init_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
