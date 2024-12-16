extends GridMap

@export var sceleton: PackedScene
var spawners = []
var spawnedSceletons = 0
var raid_active = true
var raid_number = 0


func _ready() -> void:
    Dialogic.start("testTimeline")
    for child in get_children():
        if child is Marker3D:
            spawners.append(child)


func _process(delta: float) -> void:
    if Dialogic.VAR.raidStart == true:
        raid_active = true
        raid_number += 1
        $Timer.start()
        Dialogic.VAR.raidStart = false
    pass


func check_raid_status():
    if get_child_count() == 5 and $Timer.is_stopped() and raid_active == true:
        raid_active = false
        spawnedSceletons = 0
        Dialogic.start("dialogueBeforeWave"+str(raid_number+1))

func _on_timer_timeout() -> void:
    var sceleton_instance = sceleton.instantiate()
    sceleton_instance.player = $"../mage"
    sceleton_instance.global_position = spawners.pick_random().global_position
    add_child(sceleton_instance)
    spawnedSceletons += 1
    if spawnedSceletons == int(Dialogic.VAR.skeletonWave):
        $Timer.stop()
