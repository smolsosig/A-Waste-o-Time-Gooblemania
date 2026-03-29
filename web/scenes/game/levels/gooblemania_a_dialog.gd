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

	villager_run1 = "CHARLIE, ARE YOU THERE? [b]F---ING [shake]RUN LIKE HELL!!![/shake][/b] WE'LL GUIDE YOU, [shake][b]GO![/b][/shake]",
}
