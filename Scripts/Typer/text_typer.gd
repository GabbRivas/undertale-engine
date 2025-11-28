# Typer.gd
extends Control

@onready var Text = self
@onready var Typer : TyperData

var persistent : bool = false
var muteCharacters : Array[String] = ["", " ", "^", "!", "?", ",", ".", ";", "/", "*"]

var commandIndex : Array[String] = ["instant", "skip", "persis", "pause", "speed", "voice", "face", "trigger_event", "progression", "choice"]
enum TYPER_COMMAND {
	INSTANT, SKIP, PERSISTENCE, PAUSE, SPEED, VOICE, FACE, EVENT, PROGRESSION, CHOICE
}

signal text_begin(entry : String, displayed_text : String)
signal text_end(displayed_text : String)
signal text_skipped(entry : String)
signal text_accepted(entry : String)
signal face_trigger(face : String)
signal event_triggered(event : String)

var override_speed : float = 0

func parseTyper() -> void:
	var regex = RegEx.new()
	regex.compile("\\{([a-zA-Z_]+)(?::([^}]*)?)?\\}")
	
	var output_text: String = ""
	var last_end : int = 0
	var matches = regex.search_all(Typer.raw_text)
	
	for m in matches:
		var pre_text = Typer.raw_text.substr(last_end, m.get_start() - last_end)
		
		output_text += pre_text
		last_end = m.get_end()
		
		var cmd_name = m.get_string(1).to_lower()
		
		if commandIndex.has(cmd_name):
			Typer.cmd.append(commandIndex.find(cmd_name))
			Typer.cmd_magnitude.append(m.get_string(2).strip_edges() if m.get_string(2) else "")
			Typer.cmd_position.append(max(0,output_text.length()-1))
			#Indexing is one lesser
		
		Typer.displayedText = output_text + Typer.raw_text.substr(last_end, Typer.raw_text.length())
	if matches.is_empty(): Typer.displayedText = Typer.raw_text

func execCommand(cmd, magnitude) -> void:
	match cmd:
		TYPER_COMMAND.INSTANT: Typer.instant = bool(int(magnitude))
		TYPER_COMMAND.SKIP: Typer.skippable = bool(int(magnitude)) 
		TYPER_COMMAND.PERSISTENCE: persistent = bool(int(persistent))
		TYPER_COMMAND.PAUSE: override_speed = float(magnitude)
		TYPER_COMMAND.SPEED: Typer.text_speed = float(magnitude)
		TYPER_COMMAND.VOICE: Typer.text_voice = magnitude
		TYPER_COMMAND.FACE: emit_signal("face_trigger", magnitude)
		TYPER_COMMAND.EVENT: emit_signal("event_triggered", magnitude)
		TYPER_COMMAND.PROGRESSION: Typer.character_progression = int(magnitude)

func Type() -> void:
	
	override_speed=Typer.text_speed
	
	while Typer.cmd_position.size() > 0 and Typer.cmd_position.has(Text.visible_characters):
		Typer.cmd_position.pop_front()
		execCommand(Typer.cmd.pop_front(), Typer.cmd_magnitude.pop_front())
	
	if Audio.VOICES.has(Typer.text_voice) and not muteCharacters.has(Text.text[Text.visible_characters-1]) and Text.visible_characters % Typer.character_progression == 0 and not Typer.instant:
		Audio.playSFX(Audio.VOICES.get(Typer.text_voice)[randi_range(0, Audio.VOICES.get(Typer.text_voice).size() -1)])
	
	if Text.visible_characters < Typer.displayedText.length():
		Text.visible_characters += 1 
		if (Text.visible_characters % Typer.character_progression == 0 and not Typer.instant) or (Text.visible_characters % Typer.character_progression != 0 and override_speed!=Typer.text_speed): 
			await get_tree().create_timer(override_speed).timeout
		Type()
	else:
		emit_signal("text_end", Typer.displayedText)

#I think its best to do this when the paragraph pops-up, "constant lag" is better than a lag spike
func registerTyper(entry : String) -> void:
	Text.visible_characters = 0
	Typer = TyperData.new()
	
	var temp_label = RichTextLabel.new()
	temp_label.bbcode_enabled=true
	temp_label.text = entry
	Typer.raw_text = temp_label.get_parsed_text()
	temp_label.queue_free()
	parseTyper()
	var regex = RegEx.new()
	regex.compile("\\{([a-zA-Z_]+)(?::([^}]*)?)?\\}")
	Text.text=regex.sub(entry, "", true)
	emit_signal("text_begin", entry, Typer.displayedText)
	Type()

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and Text.visible_characters < Text.text.length():
		Typer.instant=true
		emit_signal("text_skipped", Typer.displayedText)
	elif event.is_action_pressed("ui_accept"):
		emit_signal("text_accepted", Typer.displayedText)
		if not persistent: queue_free()
