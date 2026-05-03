extends Node

@onready var music : AudioStreamPlayer = $Music
@onready var sfx : AudioStreamPlayer = $SFX

var musicSliderValue : float = 50.0
var sfxSliderValue : float = 50.0

var priorityPlaying : bool = false

var gameBGM = preload("res://Sound/Music/BulletHellSong.wav")
var deathBGM = preload("res://Sound/Music/BulletHellDeathJingle.wav")

var parryHitSound = preload("res://Sound/SFX/ParryPing8Bit_SFX.wav")
var parryMissSound = preload("res://Sound/SFX/Swing8Bit_SFX.wav")
var takeDamageSound = preload("res://Sound/SFX/TakeDamage8Bit_SFX.wav")
var healingSound = preload("res://Sound/SFX/HealthGain8Bit_SFX.wav")
var deathSound = preload("res://Sound/SFX/ExplosionDeath8Bit_SFX.wav")
var clickSound = preload("res://Sound/SFX/UISelect8Bit_SFX.wav")

func _ready() -> void:
	music.volume_db += -5.0
	sfx.volume_db += 2.5

func playMusic(stream: AudioStream):
	if (music.stream != stream):
		music.stream = stream
		music.play()

func playSFX(stream: AudioStream, priority: bool = false):
	if priorityPlaying:
		return
	sfx.stream = stream
	sfx.play()
	if priority:
		priorityPlaying = true
		await sfx.finished
		priorityPlaying = false

func setVolume(player : AudioStreamPlayer, volume : float):
	player.volume_db = volume
