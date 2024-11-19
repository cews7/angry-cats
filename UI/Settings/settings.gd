extends Control

@onready var preview_rect = $ColorRect
@onready var r_slider = $VBoxContainer/RContainer/RSlider
@onready var g_slider = $VBoxContainer/GContainer/GSlider
@onready var b_slider = $VBoxContainer/BContainer/BSlider
@onready var r_value = $VBoxContainer/RContainer/RValue
@onready var g_value = $VBoxContainer/GContainer/GValue
@onready var b_value = $VBoxContainer/BContainer/BValue
@onready var save_button = $SaveButton
@onready var back_button = $BackButton

var temp_color: Color

func _ready():
    # Set up sliders
    for slider in [r_slider, g_slider, b_slider]:
        slider.min_value = 0.0
        slider.max_value = 1.0
        slider.step = 0.01
        slider.value_changed.connect(_on_color_changed)
    
    # Set initial values
    var current_color = GameState.get_background_color()
    temp_color = current_color
    r_slider.value = current_color.r
    g_slider.value = current_color.g
    b_slider.value = current_color.b
    update_preview()
    
    save_button.pressed.connect(_on_save_pressed)
	
func _on_color_changed(_value):
    update_preview()

func update_preview():
    temp_color = Color(r_slider.value, g_slider.value, b_slider.value)
    preview_rect.color = temp_color
    
    # Update value labels
    r_value.text = "%.2f" % r_slider.value
    g_value.text = "%.2f" % g_slider.value
    b_value.text = "%.2f" % b_slider.value


func _on_save_pressed():
    GameState.set_background_color(temp_color)
    SaveManager.save_settings()
    save_button.text = "Saved!"
    await get_tree().create_timer(1.0).timeout
    save_button.text = "Save"