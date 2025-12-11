extends Node

@onready var bus_layout : Dictionary = {}
@onready var voices : Dictionary = {}
@onready var sound_effects : Dictionary = {}

var bgm_list : Dictionary = {}

func play_sfx(sfx : AudioStream, bus : StringName = "SFX") -> AudioStreamPlayer:
	if not sfx: return null
	
	var stream := AudioStreamPlayer.new()
	add_child(stream)
	
	stream.stream = sfx
	stream.bus = bus
	stream.connect("finished", Callable(stream, "queue_free"))
	stream.play()
	return stream

func play_bgm(bgm: AudioStream, channel: Variant, loop : bool = true, bus : StringName = "BGM") -> AudioStreamPlayer:
	if channel in bgm_list and bgm_list[channel].stream == bgm and loop: return null
	
	var stream := AudioStreamPlayer.new()
	add_child(stream)
	if bgm is AudioStreamOggVorbis or bgm is AudioStreamMP3:
		bgm.loop = loop
	elif bgm is AudioStreamWAV:
		bgm.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	stream.stream = bgm
	stream.bus = bus
	stream.connect("finished", Callable(stream, "queue_free"))
	bgm_list[channel] = stream
	stream.play()
	return stream
