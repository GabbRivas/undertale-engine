# GlobalAudio.gd
extends Node

@onready var BUS_LAYOUT = {
	"default": load("res://Layouts/audio_bus_layout.tres"),
}
@onready var VOICES = {
	"voice.default": [ preload("res://Audio/Voices/Default_Talk.wav") ],
	"voice.narrator": [ preload("res://Audio/Voices/Narrator_Voice.ogg") ]
	# Add more: "voice_key": [ preload(...), preload(...) ]
}

var BGM_LIST = {}

func _ready():
	adjustVolume()

func adjustVolume():
	if BUS_LAYOUT.has("default"):
		AudioServer.set_bus_layout(BUS_LAYOUT["default"])

func playSFX(sfx:AudioStream, bus:StringName="SFX")->AudioStreamPlayer:
	if not sfx:
		return null
	var stream := AudioStreamPlayer.new()
	add_child(stream)
	stream.stream = sfx
	stream.bus = bus
	stream.connect("finished", Callable(stream, "queue_free"))
	stream.play()
	return stream

func playBGM(bgm:AudioStream, channel:Variant, loop:bool=true, bus:StringName="BGM")->AudioStreamPlayer:
	if (channel in BGM_LIST) and (BGM_LIST[channel].stream == bgm) and loop:
		return null
	var stream := AudioStreamPlayer.new()
	add_child(stream)
	if bgm is AudioStreamOggVorbis or bgm is AudioStreamMP3:
		bgm.loop = loop
	elif bgm is AudioStreamWAV:
		bgm.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.stream = bgm
	stream.bus = bus
	stream.connect("finished", Callable(stream, "queue_free"))
	BGM_LIST[channel] = stream
	stream.play()
	return stream

func stopBGM(channel:Variant)->void:
	if channel in BGM_LIST:
		BGM_LIST[channel].stop()
		BGM_LIST[channel].queue_free()
		BGM_LIST.erase(channel)

func register_voice(voice_key:String, sample:AudioStream) -> void:
	if not VOICES.has(voice_key):
		VOICES[voice_key] = []
	VOICES[voice_key].append(sample)
