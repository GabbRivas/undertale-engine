class_name Typer
extends Control

signal typing_begun(text_typer : TyperData)
signal choice_ready(choice_positions : Array[Vector2])
signal face_changed(face_id : String)
signal event_trigerred(event_indicator : String)
signal speaker_changed(new_speaker : String)

enum TyperCommands {
	INSTANT, SKIP, PERSISTENCE, PAUSE, SPEED, 
	VOICE, FACE, EVENT, PROGRESSION, CHOICE, SPEAKER
}

const MUTE_CHARACTERS : Array[String] = ["", " ", "^", "!", "?", ",", ".", ";", "/", "*"]
const COMMAND_INDEX : Array[String] = ["instant", "skip", "persis", "pause", "speed", "voice", "face", "trigger_event", "progression", "choice", "speaker"]
const PARSING_PARAM : String = "\\{([a-zA-Z_]+)(?::([^}]*)?)?\\}"

@export var dialogue_file : String = ""
@export var typer : TyperData
@export var persistent : bool = false

var dialogue_queue : Array = []
var override_speed : float = 0
var choice_count : int = 0

@onready var Text = $TextLabel
@onready var Cover = $CoverLabel
@onready var Regex = RegEx.new()

func get_json_dialogue() -> void: # Should perhaps also include the ability to just feed an array into the Typer
	var data : Dictionary = StringHandler.get_json(dialogue_file)
	if data.has("dialogues"):
		dialogue_queue.clear()
		for diag in data["dialogues"]:
			dialogue_queue.append(diag)
	else:
		dialogue_queue.append(data.get("text"))

func init_text() -> void:
	if dialogue_queue.is_empty(): return
	
	clone_richtext_theme(Text, Cover)
	var entry = dialogue_queue.pop_front()
	Text.visible_characters = 0
	
	typer = TyperData.new()
	typer.entry_text = entry
	Cover.text = typer.entry_text
	typer.raw_text = Cover.get_parsed_text()
	Regex.compile(PARSING_PARAM)
	typer.displayed_text = Regex.sub(typer.entry_text, "", true)
	setup_typer()
	Text.text=typer.displayed_text
	type_text()

func type_text() -> void:
	override_speed = typer.text_speed
	
	while typer.cmd_position.size() > 0 and typer.cmd_position[0] == Text.visible_characters:
		typer.cmd_position.pop_front()
		execute_command(typer.cmd.pop_front(), typer.cmd_magnitude.pop_front())
	
	if Audio.voices.has(typer.text_voice) and not MUTE_CHARACTERS.has(Text.text[Text.visible_characters-1]) and Text.visible_characters % typer.character_progression_index == 0 and not typer.instant:
		Audio.play_sfx(Audio.voices.get(typer.text_voice).pick_random())
	
	if Text.visible_characters < Text.get_parsed_text().length():
		Text.visible_characters+=1
		if (Text.visible_characters % typer.character_progression_index == 0 and not typer.instant) or (Text.visible_characters % typer.character_progression_index != 0 and override_speed != typer.text_speed):
			await get_tree().create_timer(override_speed).timeout
		type_text()

func execute_command(command : int, magnitude : String) -> void:
	match command:
		TyperCommands.INSTANT: typer.instant = bool(int(magnitude))
		TyperCommands.SKIP: typer.skippable = bool(int(magnitude))
		TyperCommands.PERSISTENCE: persistent = bool(int(magnitude))
		TyperCommands.PAUSE: override_speed = float(magnitude)
		TyperCommands.SPEED: 
			typer.text_speed = float(magnitude)
			override_speed = float(magnitude)
		TyperCommands.VOICE: typer.text_voice = magnitude
		TyperCommands.FACE: emit_signal("face_changed", magnitude)
		TyperCommands.EVENT: emit_signal("event_trigerred", magnitude)
		TyperCommands.PROGRESSION: typer.character_progression_index = int(magnitude)
		TyperCommands.CHOICE:
			choice_count += 1
			if choice_count == typer.choices: emit_signal("choice_ready")
		TyperCommands.SPEAKER:
			emit_signal("speaker_changed", magnitude)

func setup_typer() -> void:
	Regex.compile(PARSING_PARAM)
	
	var output_str : String = ""
	var cut_index : int = 0
	
	var matches = Regex.search_all(typer.raw_text)
	var bb_matches = Regex.search_all(typer.entry_text)
	
	for cmd in matches.size():
		
		var cmdlet = matches[cmd].get_string(1).to_lower()
		var cmd_value = matches[cmd].get_string(2).strip_edges() if matches[cmd].get_string(2) else ""
		
		var previous_text = typer.raw_text.substr(cut_index, matches[cmd].get_start() - cut_index)
		output_str += previous_text
		cut_index = matches[cmd].get_end()
		
		if COMMAND_INDEX.has(cmdlet):
			var cmd_index = COMMAND_INDEX.find(cmdlet)
			var cmd_pos = max(0, output_str.length()-1)
			
			typer.cmd.append(cmd_index)
			typer.cmd_magnitude.append(cmd_value)
			typer.cmd_position.append(cmd_pos)
			
			match cmd_index:
				TyperCommands.CHOICE:
					
					Cover.text=Regex.sub(typer.entry_text.left(bb_matches[cmd].get_end()), "", true)
					Cover.visible_characters=-1
					
					Cover.queue_redraw()
					await get_tree().process_frame

					var line = Cover.get_line_count()-1
					var Marker : Marker2D = Marker2D.new()
					add_child(Marker)
					Marker.position = Vector2(Cover.get_line_width(line), Cover.get_line_offset(line)+Cover.get_line_height(line)/2.0)
					
	typer.choices = typer.choice_positions.size()

func clone_richtext_theme(origin : RichTextLabel, target : RichTextLabel):
	target.size=origin.size
	
	for type_name in ["line_separation","paragraph_separation","shadow_offset_x","shadow_offset_y","text_highlight_h_padding","text_highlight_v_padding","table_h_separation","table_v_separation"]:
		if origin.has_theme_constant_override(type_name):
			target.add_theme_constant_override(type_name, origin.get_theme_constant(type_name))
	
	for type_name in ["normal_font","bold_font","bold_italics_font","italics_font","mono_font"]:
		if origin.has_theme_font_override(type_name):
			target.add_theme_font_override(type_name, origin.get_theme_font(type_name))
	
	for type_name in ["normal_font_size","bold_font_size","bold_italics_font_size","italics_font_size","mono_font_size"]:
		if origin.has_theme_font_size_override(type_name):
			target.add_theme_font_size_override(type_name, origin.get_theme_font_size(type_name))
