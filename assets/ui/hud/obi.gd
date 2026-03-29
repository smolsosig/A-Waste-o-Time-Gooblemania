extends CanvasLayer

@onready var obi_sprite: Sprite2D = $ObiSprite

func _ready() -> void:
	obi_sprite.texture = Staglobals.current_stage_obi
	$GameAnimationPlayer.play("init")

func _on_game_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
