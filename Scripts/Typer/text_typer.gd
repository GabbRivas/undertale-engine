# Typer.gd
extends Control

class TyperData:
	var trueText: String = ""
	var cmdlets: Array = []            # command names e.g. ["pause","choice",...]
	var cmdletsPositions: Array = []   # visible positions (ints)
	var cmdletsValues : Array = []     # command values (strings)
	# convenience: choices_map pos -> Array[string]
	var choices_map := {}

class TyperCommand:
	var command:String = ""
	var magnitude:String = ""

# === Nodes & naming (adjust names if your scene uses different ones) ===
@onready var Text := $Text                                   # RichTextLabel
@onready var Temps := $Temps                                 # Timer for typing tick
@onready var PauseTimer := $PauseTimer                       # Timer for pause durations
@onready var ChoiceSprite := $ChoiceSprite                   # Sprite2D for arrow/heart (optional)

# Keep your original variables
@onready var Skippable: bool = false
@onready var Persistence: bool = true
@onready var Paragraphs: Array = []

@onready var Typer : TyperData = TyperData.new()
@onready var Voice := "default"
@onready var TyperFont := 0
@onready var Speed := 0.03
@onready var Progression := 1

signal text_initiated
signal text_end
signal face_change(id)
signal trigger_event(id)
signal choice_requested(options:Array) # UI hook if you want external handling

# internal
var muteCharacters = ["", " ", "^", "!", "?", ",", ";", "/", "*", "\t"]
var commandIndex = ["skip","persis","pause","speed","voice", "face","trigger_event","choice"]
enum TYPER_COMMAND_INDEXES {
	TEXT_SKIPPABLE, TYPER_PERSISTENT, TEXT_PAUSE, TYPER_SPEED, TYPER_VOICE, TYPER_FACE_CHANGE, TRIGGER_EVENT, SET_CHOICE
}
