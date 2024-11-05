extends Node3D

# Змінні для позиції та напрямку камери
@export var target_position: Vector3  # Точка, до якої летить снаряд
var velocity: Vector3  # Змінна для швидкості
var speed: float = 10.0  # Швидкість ракети


# Викликається кожного кадру. 'delta' - це час, що минув від попереднього кадру.
func _process(delta: float) -> void:
    # Рухаємо ракету вперед у напрямку цільової точки
    position += velocity * delta  

func _on_area_3d_body_entered(body: Node3D) -> void:
    if body.is_in_group("enemies"):
        body.queue_free()  # Знищуємо ворога при зіткненні
        queue_free()  # Знищуємо ракету
