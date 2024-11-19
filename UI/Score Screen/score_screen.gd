extends Control

@onready var total_score_label = %TotalScoreLabel
@onready var restart_game_button = %RestartGameButton
@onready var exit_game_button = %ExitGameButton
@onready var main_menu_button = %MainMenuButton
@onready var score_progress_bar = %ScoreProgressBar

var current_display_score: float = 0
var target_score: int = 0
var max_possible_score: int = 0
var animation_duration: float = 1.5  # Duration in seconds
var animation_time: float = 0

func _ready():
    target_score = GameState.get_total_score()
    max_possible_score = GameState.get_max_possible_score()
    score_progress_bar.max_value = max_possible_score
    score_progress_bar.value = 0
    animation_time = 0
    current_display_score = 0
    # Start the animation
    set_process(true)
    restart_game_button.pressed.connect(_on_restart_game_pressed)
    exit_game_button.pressed.connect(_on_exit_game_pressed)
    main_menu_button.pressed.connect(_on_main_menu_pressed)

func _process(delta):
    if animation_time < animation_duration:
        animation_time += delta
        # Use ease_out for smooth deceleration
        var t = ease(animation_time / animation_duration, 0.5)  # You can adjust this ease value
        current_display_score = lerp(0.0, float(target_score), t)
        total_score_label.text = "Total Score: %d/%d" % [int(current_display_score), max_possible_score]
        score_progress_bar.value = current_display_score
    else:
        # Ensure we end on the exact number
        total_score_label.text = "Total Score: %d/%d" % [target_score, max_possible_score]
        score_progress_bar.value = target_score
        set_process(false)

func _on_exit_game_pressed():
    get_tree().quit()

func _on_restart_game_pressed():
    GameState.reset_score()
    get_tree().change_scene_to_file("res://Levels/level_one.tscn")

func _on_main_menu_pressed():
    GameState.reset_score()
    get_tree().change_scene_to_file("res://UI/Title Menu/title_menu.tscn")
