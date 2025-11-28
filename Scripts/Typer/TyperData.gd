class_name TyperData
extends Resource

var raw_text : String
var displayedText : String

var skippable : bool = true
var instant : bool = false

var character_progression : int = 1
var text_speed=0.033
var text_voice="voice.narrator"

#Godot is better managing three arrays of 2xInt32 and 1xPackedStringArray rather than an array of a dic
var cmd : Array
var cmd_magnitude : Array
var cmd_position : Array
