extends Node

const SAVE_PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
    load_settings()

func save_settings():
    var color = GameState.get_background_color()
    config.set_value("settings", "background_color_r", color.r)
    config.set_value("settings", "background_color_g", color.g)
    config.set_value("settings", "background_color_b", color.b)
    config.save(SAVE_PATH)

func load_settings():
    var err = config.load(SAVE_PATH)
    if err != OK:
        return # If no save file exists, use default values
        
    var r = config.get_value("settings", "background_color_r", 0.0)
    var g = config.get_value("settings", "background_color_g", 0.0)
    var b = config.get_value("settings", "background_color_b", 0.0)
    GameState.set_background_color(Color(r, g, b))