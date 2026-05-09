extends Node

@onready var musicPlayer : AudioStreamPlayer = $Music
@onready var sfxPlayers : Array[AudioStreamPlayer] = [$SFX1, $SFX2, $SFX3, $SFX4, $SFX5, $SFX6, $SFX7, $SFX8]

var musicSliderValue : float = 50.0
var sfxSliderValue : float = 50.0

var priorityPlaying : bool = false

var gameBGM = preload("res://Sound/Music/BulletHellSong.wav")
var deathBGM = preload("res://Sound/Music/BulletHellDeathJingle.wav")

var parryHitSound = preload("res://Sound/SFX/ParryPing8Bit_SFX.wav")
var parryMissSound = preload("res://Sound/SFX/Swing8Bit_SFX.wav")
var chainSound = preload("res://Sound/SFX/ChainCombo8Bit_SFX.wav")
var ricochetSound = preload("res://Sound/SFX/Ricochet8Bit_SFX.wav")
var bigRicochetSound = preload("res://Sound/SFX/RicochetBig8Bit_SFX.wav")
var takeDamageSound = preload("res://Sound/SFX/TakeDamage8Bit_SFX.wav")
var healingSound = preload("res://Sound/SFX/HealthGain8Bit_SFX.wav")
var deathSound = preload("res://Sound/SFX/ExplosionDeath8Bit_SFX.wav")
var clickSound = preload("res://Sound/SFX/UISelect8Bit_SFX.wav")
var mouseOverSound = preload("res://Sound/SFX/UIMouseOver8Bit_SFX.wav")
var pauseSound = preload("res://Sound/SFX/Pause8Bit_SFX.wav")
var unpauseSound = preload("res://Sound/SFX/Unpause8Bit_SFX.wav")

func playMusic(stream: AudioStream):
	if (musicPlayer.stream != stream):
		musicPlayer.stream = stream
		musicPlayer.play()

func playSFX(stream: AudioStream, priority: bool = false, quiet: bool = false):
	var player = sfxPlayers.filter(func(p): return !p.playing).front()
	if player:
		for sfxPlayer in sfxPlayers:
			# don't play if a priority sound is playing
			if sfxPlayer.bus == &"Priority" && sfxPlayer.playing && priority == false:
				return
			
			# stop all similar sounds
			if sfxPlayer.stream == stream:
					sfxPlayer.stop()
		
		# prevent likely cases of overlapping sounds
		if stream == chainSound:
			for sfxPlayer in sfxPlayers:
				if sfxPlayer.stream == parryHitSound || sfxPlayer.stream == ricochetSound:
					sfxPlayer.stop()
		if stream == deathSound:
			for sfxPlayer in sfxPlayers:
				if sfxPlayer.stream == takeDamageSound:
					sfxPlayer.stop()
		
		# play sound
		if priority:
			player.bus = &"Priority SFX"
			player.stream = stream
			
			# stop all other sounds
			for sfxPlayer in sfxPlayers:
				if sfxPlayer.bus != &"Priority" && sfxPlayer.playing:
					sfxPlayer.stop()
			
			player.play()
		elif quiet:
			player.bus = &"Quiet SFX"
			player.stream = stream
			player.play()
		else:
			player.bus = &"SFX"
			player.stream = stream
			player.play()

func setSFXVolume(db: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Priority SFX"), db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Quiet SFX"), db - 4.5)

func setMusicVolume(db: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)
