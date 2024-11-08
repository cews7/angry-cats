extends Node2D

signal bounce_value_changed(value: float, instance_id: int)

var my_instance_id: int
@onready var bounce_slider: VSlider = $BounceSlider
@onready var bounce_value_label: RichTextLabel = $BounceValue
@onready var current_bounce: float = 0.0
@onready var min_bounce: float = 0.0
@onready var max_bounce: float = 100.0

func setup(instance_id: int) -> void:
    my_instance_id = instance_id
    if bounce_slider:
        bounce_slider.value = current_bounce

func _ready() -> void:
    # set slider values
    bounce_slider.min_value = min_bounce
    bounce_slider.max_value = max_bounce
    bounce_slider.value = current_bounce
    # Connect the slider's value_changed signal
    bounce_slider.value_changed.connect(_on_slider_value_changed)

func _on_slider_value_changed(value: float) -> void:
    current_bounce = value
    bounce_value_changed.emit(current_bounce / 100.0, my_instance_id)  # Convert to 0-1 range when emitting


