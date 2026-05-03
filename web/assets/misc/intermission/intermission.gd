extends CanvasLayer

signal yeah_we_done

@export var debug: bool = false
var artworks: Array[Sprite2D]
@onready var ad_cooldown_timer: Timer = $AdCooldown
var wait_time: float
@onready var music: AudioStreamPlayer = $AwesomeMusic

var skipped: bool = false

func _ready() -> void:
	SignalBus.connect("reset", _reset)
	wait_time = ad_cooldown_timer.wait_time
	_reset()
	
	if debug: start_intermission()
	
	for child in $Ads.get_children():
		artworks.push_back(child)
	
func _reset() -> void:
	hide()
	skipped = false
	ad_cooldown_timer.wait_time = wait_time

func start_intermission() -> void:
	show()
	PlayerVar.showhide_cursor(true)
	$Hand/Hand.start_doing_shit = true
	$Hand/Hand/ShowHand.start()
	ad_cooldown_timer.start()

	music.play()

func next_ad() -> void:
	if artworks:
		artworks.pop_back().hide()
		
		if artworks.size() == 4:
			await get_tree().create_timer(0.5).timeout
			$CharlieVoxHuh.play()
		elif artworks.size() == 1:
			$CharlieVoxEnd.play()
			ad_cooldown_timer.wait_time *= 0.3
		
		ad_cooldown_timer.start()
		
		if !artworks.size():
			$Hand/Hand.stop_now()
			if !skipped:
				NG.medal_unlock(88395)
			var tween: Tween = create_tween()
			tween.tween_property(music, "pitch_scale", 0.01, 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			await tween.finished
			music.stop()
			await get_tree().create_timer(1).timeout
			hide()
			PlayerVar.showhide_cursor()
			yeah_we_done.emit()
