extends Control

signal level_one_button_pressed
signal level_two_button_pressed
signal level_three_button_pressed

@onready var level_one_button = %LevelOneButton
@onready var level_two_button = %LevelTwoButton 
@onready var level_three_button = %LevelThreeButton  
@onready var ui_container = $UIContainer  # Add a reference to your UI container node
var sweep_line: Line2D

func _ready() -> void:
	level_one_button.pressed.connect(_on_level_one_pressed)
	level_two_button.pressed.connect(_on_level_two_pressed)
	level_three_button.pressed.connect(_on_level_three_pressed)
	
	# Setup sweep line
	sweep_line = Line2D.new()
	add_child(sweep_line)
	sweep_line.width = 50.0
	sweep_line.default_color = Color(1, 1, 1, 0.3)
	
	# Get screen dimensions for proper positioning
	var viewport_size = get_viewport_rect().size
	var padding = 100.0
	
	# Create diagonal line points
	var start_pos = Vector2(-padding, -padding)
	var end_pos = Vector2(viewport_size.x + padding, viewport_size.y + padding)
	sweep_line.points = [start_pos, end_pos]
	sweep_line.modulate.a = 0.0

func play_transition_animation() -> void:
	var sweep_tween = create_tween()
	sweep_tween.set_trans(Tween.TRANS_SINE)
	sweep_tween.set_ease(Tween.EASE_IN_OUT)
	
	# Fade in sweep line
	sweep_tween.tween_property(sweep_line, "modulate:a", 0.8, 0.1)
	
	# Move sweep line diagonally and fade out UI
	sweep_tween.parallel().tween_property(sweep_line, "position:x", 
		get_viewport_rect().size.x + 200, 0.4).from(-200.0)
	
	# Fade out UI elements
	sweep_tween.parallel().tween_property(ui_container, "modulate:a", 0.0, 0.5)
	
	# Fade out sweep line
	sweep_tween.tween_property(sweep_line, "modulate:a", 0.0, 0.1)

func _on_level_one_pressed() -> void:
	play_transition_animation()
	await get_tree().create_timer(0.4).timeout
	level_one_button_pressed.emit()
	queue_free()

func _on_level_two_pressed() -> void:
	play_transition_animation()
	await get_tree().create_timer(0.4).timeout
	level_two_button_pressed.emit()
	queue_free()

func _on_level_three_pressed() -> void:
	play_transition_animation()
	await get_tree().create_timer(0.4).timeout
	level_three_button_pressed.emit()
	queue_free()

