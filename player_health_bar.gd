extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func set_player_hp(hp: int):
    value = hp
    if value == 0:
        $"../GameOver".show()
        get_tree().paused = true
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
