extends Node

const PROPORTION : float = 0.25 
#Obtained by dividing the FPS of undertale over the FPS of the engine 30/120 = 1/4 = 0.25

var player_name : String = "Kan"
var player_lv : int = 19
var player_hp : Variant = 92
var player_max_hp : Variant = 92
var player_money : Variant = 9999

var player_inventory : Array = []
var player_cellphone : Array = []

func get_max_hp() -> float:
	return (player_lv*4 + 16 + (7 if player_lv > 20 else 0))

func get_speaker() -> Texture2D:
	return null
