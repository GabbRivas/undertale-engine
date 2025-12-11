class_name TyperData
extends Resource

var entry_text : String
var raw_text : String
var displayed_text : String

var skippable : bool = true
var instant : bool = false

var character_progression_index : int = 1
var text_speed : float = 0.033
var text_voice : String = "voice.narrator"

var choices = 0
var choice_positions : Array[Marker2D] = []

var cmd : Array
var cmd_magnitude : Array
var cmd_position : Array
