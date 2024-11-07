extends Node2D

func play_animation() -> void:
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.5)
    tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
    tween.tween_callback(queue_free)