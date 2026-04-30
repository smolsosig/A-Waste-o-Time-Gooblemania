extends Node

var dialogue: Dictionary = {
	gooblecop1 = "(incomprehensible gibbering)",
	
	villager_help_rand1 = "Please! [b]OW![/b] All I did was just look at you! [b]OWWW!!![/b]",
	villager_help_rand2 = "[b]STOP![/b] What did I even do?!",
	villager_help_rand3 = "Ow OW [b]OW![/b] Please! I'm sorry! OW!!!",

	inspect_lighthouse1 = "That there's the old, weird lighthouse-slash-observatory thing.",
	inspect_lighthouse2 = "Those cat things have retrofitted some weird sci-fi bull[shake]s---[/shake]ery around it to form some sort of... headquarters.",
	inspect_lighthouse3 = "It's not the desecration of old landmarks that bothers you. It's the fact that what they ended up with just looked really lame.",
	inspect_lighthouse_loop1 = "That sure [b]WAS[/b] the old lighthouse, alright.",

	villager_standby1_rand1 = "Don't drink the water... Don't tap the glass...",
	villager_standby1_rand2 = "If I don't go, I starve... if I do, I die...",
	villager_standby1_rand3 = "If I stay... God. Should I stay or should I go?",
	villager_standby1_rand4 = "... same as it ever was, same as it ever was...",
	
	#region GARCIA EAST
	villager_sus_mini = "[b]PSST.[/b] Hey! Come here, quick!",
	villager_sus1 = "[b]You![/b] Head to the roof! There's a door up there, we'll open it for you!",
	villager_sus2 = "And do it now! Quickly, while [b]THEY[/b] are still on a routine search in the other side of the village!",
	
	villager_secret1 = "Are you. . . are you Charlie, by chance? . . . I called you in because I thought you matched the description.",
	villager_secret2 = "Wait. Give me a second... let me radio Garcia East...",

	villager_secret3 = ". . . Sir, this is Garcia West, do you copy? Charlie's here. Or... I think it's her. Over.",
	villager_secret4 = "Yes, sir. Red beanie, striped sweater... yes, yellow on blue. Brown hair, eerie stare... let me check sir, over.",
	villager_secret5 = "Hey. . . you're gay, right?",
	villager_secret6 = "... no response, sir. I admit I might've been too blunt. But I think she checks all the boxes, over.",
	villager_secret7 = "..... I do have it sir, yes. I'll give it to her. Yes, sir. Over and out.",

	villager_secret8 = "Alright, Charlie, or not-Charlie... yeah, you'll do. Your bat is in the next room.",
	villager_secret9 = "We need you to finally rid this village of these Goobles once and for all. This has gone on for far too long now.",
	villager_secret10 = "Go out in the back, Charlie, there's a pathway that leads straight to their headquarters. Yes, the old lighthouse. Good luck.",
	villager_secret11 = ". . . oh God. They've been beating that guy up for an hour now.",
	
	villager_futurecop1 = "... oh yeah. I- I can't be the only one who hated their stupid propaganda video game, right?",
	villager_futurecop2 = "Yeah, those Goobles made a video game. To further their influence or something. I think it was called \"A Waste o' Time: Gooblemania\".",
	villager_futurecop3 = "I heard that appointed media supervisor FutureCopLGF reviewed the game, and apparently even [b]he[/b] really disliked it so much that they... they [shake][b]got him.[/b][/shake]",
	villager_futurecop4 = "If that's true, then it's a damn shame. I liked him, too. FutureCop was a true hero who spoke what needed to be spoken.",
	villager_futurecop5 = "... oh, well.",
	villager_futurecop_loop1 = "I'll say it again and again, man. This world gets darker and darker without FutureCop in it.",
	villager_futurecop_loop2 = "We'll avenge you, FutureCop... we carry the flame...",

	villager_tutorial1 = "Hell yeah, it's your bat! We kept it... it's been cleaned up and stuff.",
	villager_tutorial2 = "It's Gooble-resistant, we made sure. You can go and hit one to death, but I don't advise standing still afterwards. Elena, you idiot...",
	villager_tutorial3 = "Practice with that wooden Gooble dummy if you wish. It's very durable. The world will end and that thing will still be standing.",
	#endregion
	
	villager_run1 = "CHARLIE, ARE YOU THERE? [b]F---ING [shake]RUN LIKE HELL!!![/shake][/b] WE'LL GUIDE YOU, [shake][b]GO![/b][/shake]",

	#region GARCIA EAST SEWERS
	radio_chatter1 = "Golf Whiskey to Golf Echo, do you copy? Don't you ever say our actual names out loud on air again. Over.",
	radio_chatter2 = "Golf Whiskey to Golf Echo Sierra. We hear Charlie's gone underground? Please confirm, over.",
	radio_chatter3 = "Oh, Charlie, is that you? Fantastic. This is Golf Whiskey. There's a direct path to Garcia North from there, but be warned, we put a [b]lot[/b] of traps in the sewers.",
	radio_chatter4 = "If you're in luck, they haven't been tested in ages... in which case, after all this, I wish to hear Golf Echo's excuses for why they [shake]HAVEN'T BEEN CALIBRATED REGULARLY.[/shake]",
	radio_chatter5 = "Good luck. Over and out.",
	
	radio_chatter_loop1 = "Golf Uniform Whiskey? Oh, Charlie. Hello!",
	radio_chatter_loop2 = "[b][shake]GO OUT ALREADY![/shake][/b] There is NO TIME TO WASTE! OVER and OUT!",
	#endregion
	
	#region GARCIA NORTH
	julie_hicharlie1 = "OH, OH! [b][wave freq=10 amp=50.0]HI CHARLIEEEE!!![/wave][/b] Welcome to Garcia North, the only one with an actual weaponry division; courtesy of us being near the village armory.",
	julie_hicharlie2 = "We've come up with a new weapon... no, [b]I[/b] did. Don't tell them, but the other guys here are all dumbbells. What's the term, \"stupid\"? Or is it \"slow\"? Maybe it's \"useless\". There's a cuter word for it...",
	julie_hicharlie3 = "[shake][b]ENOUGH CHITCHAT!!![/b][/shake] Here's your weapon, babe, ranged throwing stars! I call this one the [b]IchistAr![/b] Try it out!",
	
	julie_talk2charlie1 = "Y'know, love, someone from Garcia South kept on sending me cassette tapes of love songs.",
	julie_talk2charlie2 = "I get that maybe they like me, but I don't even like love songs... isn't that weird?",
	julie_talk2charlie3 = "What about you, babe? What do you wish people got you? Or... do you already have someone who gives you what you want?",
	
	julie_talk2charlie_loop1 = "... y'know, love, I'd maybe forgive them if they were a girl. Teehee.",
	julie_talk2charlie_loop2 = "..... I mean, uh, um. The ceiling fan looks so nice, right, babe?",
	
	julie_byecharlie1 = "Pretty good, huh? I'd love to talk more, but there's a pickup carriage in the back waiting for you.",
	julie_byecharlie2 = "Get those Goobles! Good luck, babe!",
	#endregion
	
	driver_holdon1 = "Girl, hold tight, I drive really quickly with this thing. Ne'ermind the sticker on the horse that says top speed is 30mph.",
	driver_getready1 = "Girl, get your weapons ready. . . where there's smoke, there's flying Goobles. Please tell me you know how to switch weapons, because I'm not gonna teach you to press TAB to switch to your ranged.",
	driver_wow1 = "Wow. I've never seen any of my passengers do that before.",
	driver_wow2 = "Granted, they all die immediately as soon as we get spotted...",
	driver_wow3 = "It's gonna be a little while befor we get to where we need to be, girl, so I ask you be patient. Least the hard part's over.",
}
