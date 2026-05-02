extends CanvasLayer

signal yeah_we_done

@export var debug: bool = false
var artworks: Array[Sprite2D]
@onready var ad_cooldown_timer: Timer = $AdCooldown
@onready var music: AudioStreamPlayer = $AwesomeMusic

func _ready() -> void:
	SignalBus.connect("reset", _reset)
	_reset()
	
	if debug: start_intermission()
	
	for child in $Ads.get_children():
		artworks.push_back(child)
	
func _reset() -> void:
	hide()

func start_intermission() -> void:
	show()
	PlayerVar.showhide_cursor(true)
	$Hand/Hand.start_doing_shit = true
	ad_cooldown_timer.start()

	music.play()

func next_ad() -> void:
	if artworks:
		artworks.pop_back().hide()
		
		if artworks.size() == 4:
			await get_tree().create_timer(0.3).timeout
			$CharlieVoxHuh.play()
		elif artworks.size() == 1: $CharlieVoxEnd.play()
		
		ad_cooldown_timer.start()
		
		if !artworks.size():
			$Hand/Hand.stop_now()
			var tween: Tween = create_tween()
			tween.tween_property(music, "pitch_scale", 0.01, 3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			await tween.finished
			hide()
			PlayerVar.showhide_cursor()
