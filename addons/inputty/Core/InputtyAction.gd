extends Resource
class_name InputtyAction

var name:StringName=""
var deadzone:=0.5
var inputs:Array[InputEvent]=[]

var compoundState:InputtyActionState = InputtyActionState.new() #compound state from all devices
var states:Array[InputtyActionState] = [] # state of input for each device
func getActionState(device:int=-2)->InputtyActionState:
	prepActionStates()
	if device==-2:
		return compoundState
	
	device+=1#offset because keys/mouse are device -1
	
	if device>=states.size():
		#no such device is tracked
		print("got null")
		return null
		
	return states[device]

func validState(device:int=-2)->bool:
	return device==-2 or device+1<states.size()

func refreshStates()->void:
	#updates all states except keyboard/mouse
	prepActionStates()
	
	for state in states:
		if state.device<0:
			continue
		
		state.raw_strength = 0.0
		
		for event in inputs:
			if event is InputEventJoypadButton:
				if Input.is_joy_button_pressed(state.device,event.button_index):
					state.raw_strength = 1.0
			if event is InputEventJoypadMotion:
				var axisVal:float = Input.get_joy_axis(state.device, event.axis)
				if signf(axisVal)!=signf(event.axis_value):
					axisVal = 0.0
				state.raw_strength = maxf(state.raw_strength, absf(axisVal))
		
		state.updateJusts(state.raw_strength>deadzone)
		state.pressed = state.raw_strength>deadzone
		state.strength = Inputty._rescaleFromDeadzone(state.raw_strength, deadzone)
	
	updateCompoundActionState()

func processEvent(event:InputEvent)->void:
	prepActionStates()
	
	var stateIndex = event.device+1
	for input in inputs:
		
		var modsMatch:bool = true
		if event is InputEventKey or event is InputEventMouseButton:
			if event.is_pressed() and event is InputEventWithModifiers and input is InputEventWithModifiers:
				if (event.shift_pressed!=input.shift_pressed or event.alt_pressed!=input.alt_pressed
				or event.ctrl_pressed!=input.ctrl_pressed or event.meta_pressed!=input.meta_pressed):
					modsMatch=false
		
		if modsMatch and event is InputEventKey && input is InputEventKey:
			var matched:bool = false
			if input.keycode!=0 and event.keycode==input.keycode:
				matched=true
				states[0].updateButton(states[0].keys, states[0].keysPressed, event.keycode, event.pressed)
			elif input.physical_keycode!=0 and event.physical_keycode==input.physical_keycode:
				matched=true
				states[0].updateButton(states[0].keysPhys, states[0].keysPhysPressed, event.physical_keycode, event.pressed)
			elif input.unicode!=0 and event.unicode==input.unicode:
				matched=true
				states[0].updateButton(states[0].keysUni, states[0].keysUniPressed, event.unicode, event.pressed)
			if matched:
				updateCompoundActionState()
		elif modsMatch and event is InputEventMouseButton && input is InputEventMouseButton && event.button_index==input.button_index:
			states[0].updateButton(states[0].mouseButtons, states[0].mouseButtonsPressed, event.button_index, event.pressed)
			updateCompoundActionState()
		elif stateIndex<states.size() and event is InputEventJoypadButton && input is InputEventJoypadButton && event.button_index==input.button_index:
			states[stateIndex].updateButton(states[stateIndex].joyButtons, states[stateIndex].joyButtonsPressed, event.button_index, event.pressed)
			updateCompoundActionState()
		elif stateIndex<states.size() and event is InputEventJoypadMotion && input is InputEventJoypadMotion && event.axis==input.axis:
			states[stateIndex].joyMotion(event, input)
			updateCompoundActionState()

	
func updateCompoundActionState()->void:
	#an action state has been effected, update the compound state
	compoundState.pressed = false
	compoundState.strength = 0.0
	compoundState.raw_strength = 0.0
	compoundState.just_pressed_idle = -1
	compoundState.just_pressed_physics = -1
	compoundState.just_released_idle = -1
	compoundState.just_released_physics = -1
	compoundState.pressed_time = -1
	
	for state in states:
		if state.pressed:
			compoundState.pressed = true
		compoundState.strength = maxf(compoundState.strength, state.strength)
		compoundState.raw_strength = maxf(compoundState.raw_strength, state.raw_strength)
		
		compoundState.just_pressed_idle = maxi(compoundState.just_pressed_idle, state.just_pressed_idle)
		compoundState.just_pressed_physics = maxi(compoundState.just_pressed_physics, state.just_pressed_physics)
		compoundState.just_released_idle = maxi(compoundState.just_released_idle, state.just_released_idle)
		compoundState.just_released_physics = maxi(compoundState.just_released_physics, state.just_released_physics)
		
		compoundState.pressed_time = maxi(compoundState.pressed_time, state.pressed_time)
	

func prepActionStates()->void:
	#Inputty._pollJoys()
	if states.size()>Inputty._joyCount+1:
		for state in states:
			#state.free()
			state = null
		states=[]
		
	while states.size()<Inputty._joyCount+1:
		states.append(InputtyActionState.new())
		states[states.size()-1].device = states.size()-2
		states[states.size()-1].prep()
		states[states.size()-1].action = self

func copyFrom(other:InputtyAction):
	name=other.name
	deadzone=other.deadzone
	inputs=[]
	for i in other.inputs:
		inputs.append(InputCopy(i))

func copyFromMain(actionName:StringName):
	name = actionName
	deadzone = InputMap.action_get_deadzone(actionName)
	inputs=[]
	
	var mainInputs = InputMap.action_get_events(actionName)
	for i in mainInputs:
		inputs.append(InputCopy(i))

func InputCopy(i:InputEvent):
	var newInput
	if i is InputEventMouseButton:
		newInput = InputEventMouseButton.new()
		newInput.button_index = i.button_index
	elif i is InputEventMIDI:
		newInput = InputEventMIDI.new()
		newInput.channel = i.channel
		newInput.controller_number = i.controller_number
	elif i is InputEventKey:
		newInput = InputEventKey.new()
		newInput.keycode = i.keycode
		newInput.physical_keycode = i.physical_keycode
		newInput.unicode = i.unicode
	elif i is InputEventJoypadButton:
		newInput = InputEventJoypadButton.new()
		newInput.button_index = i.button_index
	elif i is InputEventJoypadMotion:
		newInput = InputEventJoypadMotion.new()
		newInput.axis = i.axis
		newInput.axis_value = i.axis_value
	else:
		#null event I guess
		newInput = null
	
	if newInput is InputEventWithModifiers:
		newInput.ctrl_pressed = i.ctrl_pressed
		newInput.alt_pressed = i.alt_pressed
		newInput.meta_pressed = i.meta_pressed
		newInput.shift_pressed = i.shift_pressed
		newInput.command_or_control_autoremap = i.command_or_control_autoremap
		
	
	if newInput:
		newInput.device = -1
		
	return newInput

func prepSave(config:ConfigFile):
	var sectionName:String = "a_" + name
	var inputIndex:int = 0
	config.set_value(sectionName, "inputs", inputs.size())
	for i in inputs:
		var strindex:String = str(inputIndex)
		if i is InputEventMouseButton:
			config.set_value(sectionName, "type_"+strindex, "MouseButton")
			config.set_value(sectionName, "button_"+strindex, i.button_index)
		elif i is InputEventMIDI:
			config.set_value(sectionName, "type_"+strindex, "MIDI")
			config.set_value(sectionName, "channel_"+strindex, i.channel)
			config.set_value(sectionName, "controller_number_"+strindex, i.controller_number)
		elif i is InputEventKey:
			config.set_value(sectionName, "type_"+strindex, "Key")
			config.set_value(sectionName, "keycode_"+strindex, i.keycode)
			config.set_value(sectionName, "physical_keycode_"+strindex, i.physical_keycode)
			config.set_value(sectionName, "unicode_"+strindex, i.unicode)
		elif i is InputEventJoypadButton:
			config.set_value(sectionName, "type_"+strindex, "JoyButton")
			config.set_value(sectionName, "button_"+strindex, i.button_index)
		elif i is InputEventJoypadMotion:
			config.set_value(sectionName, "type_"+strindex, "JoyMotion")
			config.set_value(sectionName, "axis_"+strindex, i.axis)
			config.set_value(sectionName, "axis_value_"+strindex, i.axis_value)
		else:
			config.set_value(sectionName, "type_"+strindex, "NULL")
		
		if i is InputEventWithModifiers:
			if i.ctrl_pressed:
				config.set_value(sectionName, "ctrl_pressed_"+strindex, i.ctrl_pressed)
			if i.alt_pressed:
				config.set_value(sectionName, "alt_pressed_"+strindex, i.alt_pressed)
			if i.meta_pressed:
				config.set_value(sectionName, "meta_pressed_"+strindex, i.meta_pressed)
			if i.shift_pressed:
				config.set_value(sectionName, "shift_pressed_"+strindex, i.shift_pressed)
			if i.command_or_control_autoremap:
				config.set_value(sectionName, "cmdctrlremap_"+strindex, i.command_or_control_autoremap)
		
		inputIndex+=1
		
		
	
