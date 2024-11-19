extends Node

var total_score: int = 0
var background_color: Color = Color(0, 0, 0)
var max_possible_score: int = 60

signal background_color_changed(new_color: Color)

func _ready():
    # Load saved color if it exists
    if FileAccess.file_exists("user://settings.save"):
        load_settings()
    else:
        # Default color
        background_color = Color(0, 0, 0)

func add_to_score(points: int) -> void:
    total_score += points

func get_total_score() -> int:
    return total_score

func reset_score() -> void:
    total_score = 0

func get_background_color() -> Color:
    return background_color


func get_max_possible_score() -> int:
    return max_possible_score

func set_background_color(color: Color) -> void:
    background_color = color
    # Update the viewport background color directly
    RenderingServer.set_default_clear_color(color)
    emit_signal("background_color_changed", color)
    save_settings()

func save_settings() -> void:
    var save_data = {
        "background_color": {
            "r": background_color.r,
            "g": background_color.g,
            "b": background_color.b,
        }
    }
    
    var save_file = FileAccess.open("user://settings.save", FileAccess.WRITE)
    var json_string = JSON.stringify(save_data)
    save_file.store_line(json_string)

func load_settings() -> void:
    var save_file = FileAccess.open("user://settings.save", FileAccess.READ)
    var json_string = save_file.get_line()
    var json = JSON.new()
    var parse_result = json.parse(json_string)
    
    if parse_result == OK:
        var data = json.get_data()
        if data.has("background_color"):
            var color_data = data["background_color"]
            background_color = Color(
                color_data["r"],
                color_data["g"],
                color_data["b"]
            )