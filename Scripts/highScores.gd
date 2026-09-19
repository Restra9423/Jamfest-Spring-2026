extends Node

const saveLocation = "user://HighScores.json"

var toBeSaved : Dictionary = {
	"FirstPlace": {
		"playerName": "No Data",
		"score": 0,
	},
	"SecondPlace": {
		"playerName": "No Data",
		"score": 0,
	},
	"ThirdPlace": {
		"playerName": "No Data",
		"score": 0,
	},
	"FourthPlace": {
		"playerName": "No Data",
		"score": 0,
	},
	"FifthPlace": {
		"playerName": "No Data",
		"score": 0,
	}
}

var defaultValues : Dictionary = {
	"FirstPlace": {
		"playerName": "No Data",
		"score": 0,
	},
	"SecondPlace": {
		"playerName": "No Data",
		"score": 0,
	},
	"ThirdPlace": {
		"playerName": "No Data",
		"score": 0,
	},
	"FourthPlace": {
		"playerName": "No Data",
		"score": 0,
	},
	"FifthPlace": {
		"playerName": "No Data",
		"score": 0,
	}
}

func _ready() -> void:
	_load()

func _save():
	var file = FileAccess.open(saveLocation, FileAccess.WRITE)
	file.store_var(toBeSaved.duplicate())
	file.close()

func _load():
	if FileAccess.file_exists(saveLocation):
		var file = FileAccess.open(saveLocation, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		var saveData = data.duplicate()
		for key in saveData:
			if key in toBeSaved:
				toBeSaved[key] = saveData[key]

func _clear():
	for key in defaultValues:
		if key in toBeSaved:
			toBeSaved[key] = defaultValues[key].duplicate(true)
	_save()
