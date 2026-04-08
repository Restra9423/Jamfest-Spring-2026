extends Node

@onready var music : AudioStreamPlayer = $Music
@onready var sfx : AudioStreamPlayer = $SFX

var gameBGM = preload("res://Sound/Music/BulletHellSong.wav")
var deathBGM = preload("res://Sound/Music/BulletHellDeathJingle.wav")

var parryHitSound = preload("res://Sound/SFX/ParryPing8Bit_SFX.wav")
var parryMissSound = preload("res://Sound/SFX/Swing8Bit_SFX.wav")
var takeDamageSound = preload("res://Sound/SFX/TakeDamage8Bit_SFX.wav")
var healingSound = preload("res://Sound/SFX/HealthGain8Bit_SFX.wav")
var deathSound = preload("res://Sound/SFX/ExplosionDeath8Bit_SFX.wav")
var clickSound = preload("res://Sound/SFX/UISelect8Bit_SFX.wav")

var priorityPlaying : bool = false

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
