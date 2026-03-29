extends Node

func _ready() -> void:
	DiscordRPC.app_id = 1131958061670600825
	print("Discord working: " + str(DiscordRPC.get_is_discord_working()))
	DiscordRPC.details = "Yippee! Yahoo!"
	DiscordRPC.large_image = "default_00000"
	DiscordRPC.large_image_text = "AYAYAYAYAYAYAYAYAYAYA"
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()
	
	queue_free()
