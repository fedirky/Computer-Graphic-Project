extends GridMap

@export var sceleton: PackedScene
var spawners = []
var spawnedSceletons = 0


func _ready() -> void:
    for child in get_children():
        if child is Marker3D:
            spawners.append(child)


func _process(delta: float) -> void:
    print(Dialogic.VAR.raidStart)
    if Dialogic.VAR.raidStart == true:
        $Timer.start()
        Dialogic.VAR.raidStart = false
    pass


func _on_timer_timeout() -> void:
    var sceleton_instance = sceleton.instantiate()
    sceleton_instance.player = $"../mage"
    sceleton_instance.global_position = spawners.pick_random().global_position
    add_child(sceleton_instance)
    spawnedSceletons += 1
    if spawnedSceletons == 10:
        $Timer.stop()
