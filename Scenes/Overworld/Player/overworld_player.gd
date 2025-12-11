extends CharacterBody2D

signal toggle_inventory(instance : Control)

@onready var CharaSprite = $Chara
@onready var AnimPlayer = $AnimationPlayer
@onready var Collision = $CollisionShape2D

var moveable : bool = true
var inventory_moveable : bool = false

func _physics_process(_delta: float) -> void:
	pass

func is_player_moveable() -> bool:
	var is_moveable : bool = moveable
	
	return is_moveable
