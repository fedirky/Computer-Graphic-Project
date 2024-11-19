extends Node3D

# Змінні для позиції та напрямку камери
@export var camera_position: Vector3  # Позиція камери
@export var camera_direction: Vector3  # Напрямок камери
var velocity: Vector3       # Змінна для швидкості
var speed: float = 10.0     # Швидкість ракети
var is_flying_straight: bool = false  # Стан, чи ракета літає прямо
var original_direction: Vector3  # Оригінальний напрямок

# Викликається, коли об'єкт входить у дерево сцени вперше.
func _ready() -> void:
    # Обчислюємо напрямок до уявної лінії, яку створює камера
    var line_point = camera_position + camera_direction.normalized() * 10.0  # Точка на лінії
    var direction_to_line = (line_point - global_position).normalized()  # Напрямок до лінії
    velocity = direction_to_line * speed  # Встановлюємо початкову швидкість ракети
    original_direction = camera_direction.normalized()  # Зберігаємо оригінальний напрямок

# Викликається кожного кадру. 'delta' - це час, що минув від попереднього кадру.
func _process(delta: float) -> void:
    # Обчислюємо точку на лінії для напрямку
    var line_point = camera_position + camera_direction.normalized() * 10.0  # Точка на лінії
    var direction_to_line = (line_point - global_position).normalized()  # Напрямок до лінії

    if not is_flying_straight:
        # Плавно оновлюємо напрямок до лінії
        velocity = velocity.lerp(direction_to_line * speed, 0.1)  # Лінійна інтерполяція

        # Перевіряємо, якщо ракета близько до уявної лінії (наближається)
        if global_position.distance_to(line_point) < 0.5:
            is_flying_straight = true  # Вмикаємо стан для прямого польоту
            velocity = original_direction * speed  # Встановлюємо швидкість у напрямку оригінальної траєкторії

    # Рухаємо ракету вперед
    position += velocity * delta  

func _on_area_3d_body_entered(body: Node3D) -> void:
    if body.is_in_group("enemies"):
        body.queue_free()  # Знищуємо ворога при зіткненні
        queue_free()  # Знищуємо ракету
