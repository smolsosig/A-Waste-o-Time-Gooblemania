extends AnimatedSprite2D

func blare(stoppy: bool = true) -> void:
	if !stoppy:
		play("blaring")
	else:
		play("idle")
