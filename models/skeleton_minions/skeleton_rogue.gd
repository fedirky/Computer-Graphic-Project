extends CharacterBody3D

@export var player: Node3D  # Шлях до гравця, щоб моб міг його знайти
@onready var animation_player = $AnimationPlayer  # Animation Player for the character

var current_animation: String = ""  # Internal variable to track the current animation
var is_attacking: bool = false  # Flag to track attack state

var SPEED = 4.0
const LERP_AFK_SPEED = 50.0
const JUMP_VELOCITY = 4.5 * 2
const BLEND_TIME = 0.2  # Desired blend time between animations
const ATTACK_DISTANCE = 1.5  # Distance to trigger the attack
const ATTACK_DURATION = 1.1  # Time in seconds for the attack animation
var hp = 2

var direction: Vector3 = Vector3.ZERO  # Direction the character is moving

func _ready():
    animation_player.play("Idle")
    set_animation_loop_mode("Idle", true)  # Example of setting loop mode for an animation
    set_animation_loop_mode("Running_B", true)  # Ensure "Run" animation is loopable
    set_animation_loop_mode("2H_Melee_Attack_Slice", true)
    set_animation_loop_mode("Death_A", true)

func _physics_process(delta: float) -> void:
    if not player:
        return  # Exit if player node is not assigned or doesn't exist

    # Перевірити чи hp моба <= 0
    if hp <= 0:
        play_animation("Death_A")
        await get_tree().create_timer(0.8).timeout
        queue_free()  # Видалити моб після анімації смерті
        return

    # Обчислити напрямок руху до гравця
    var target_position = player.global_position
    var distance_to_player = (target_position - global_position).length()

    # Якщо моб атакує, пропустити всі інші дії, поки атака не завершена
    if is_attacking:
        return

    # Враховувати тільки горизонтальну площину для руху
    direction = (target_position - global_position).normalized()
    direction.y = 0

    if distance_to_player <= ATTACK_DISTANCE:
        await start_attack()  # Розпочати атаку
        return

    # Якщо моб стоїть на підлозі
    if is_on_floor():
        if direction.length() > 0:  # Якщо є напрямок руху
            play_animation("Running_B")  # Переключити анімацію на "Run"
        else:
            play_animation("Idle")  # Переключити анімацію на "Idle"

    # Розрахунок швидкості
    if direction.length() > 0:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED

        # Обчислення повороту моба до напрямку руху
        var local_target_rotation = atan2(direction.x, direction.z)
        var current_rotation = rotation.y
        rotation.y = lerp_angle(current_rotation, local_target_rotation, 0.1)
    else:
        # Сповільнення, якщо немає руху
        velocity.x = lerp(velocity.x, 0.0, LERP_AFK_SPEED * delta)
        velocity.z = lerp(velocity.z, 0.0, LERP_AFK_SPEED * delta)

    # Додати гравітацію, якщо не на підлозі
    if not is_on_floor():
        velocity += 2 * get_gravity() * delta
    else:
        velocity.y = 0  # Скинути вертикальну швидкість, якщо моб на підлозі

    move_and_slide()

# Function to start an attack
# Function to start an attack
func start_attack() -> void:
    is_attacking = true
    play_animation("2H_Melee_Attack_Slice")  # Змінити на назву вашої анімації атаки
    velocity = Vector3.ZERO  # Зупинити моба

    if not player:
        is_attacking = false
        return

    var timer = get_tree().create_timer(ATTACK_DURATION)

    while timer.time_left > 0:
        # Отримати напрямок до гравця
        var target_position = player.global_position
        var attack_direction = (target_position - global_position).normalized()
        attack_direction.y = 0  # Враховувати тільки горизонтальну площину

        # Плавний поворот до гравця
        var local_target_rotation = atan2(attack_direction.x, attack_direction.z)
        var current_rotation = rotation.y
        rotation.y = lerp_angle(current_rotation, local_target_rotation, 0.2)

        await get_tree().process_frame  # Очікування наступного кадру

    # Перевірити, чи гравець все ще в межах ATTACK_DISTANCE
    var distance_to_player = (player.global_position - global_position).length()
    if distance_to_player <= ATTACK_DISTANCE:
        # Видалити гравця зі сцени
        player.reduce_hp(1)
    is_attacking = false  # Завершити атаку


# Function to reduce hp and handle death
func reduce_hp(amount: int) -> void:
    hp -= amount

# Function to set the loop mode of an animation
func set_animation_loop_mode(anim_name: String, loop: bool) -> void:
    var anim = animation_player.get_animation(anim_name)
    if anim:
        anim.loop_mode = loop
    else:
        print("Animation", anim_name, "not found!")

# Function to play animations safely
func play_animation(anim_name: String) -> void:
    if current_animation != anim_name:  # Play only if a new animation is requested
        animation_player.play(anim_name, 0.2)
        current_animation = anim_name
