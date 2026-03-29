extends Control
class_name InputRemap

signal exit_requested

@export var actionNames:Array[StringName]
@export var actionDisplayNames:Array[String]

@export var actionRebindPrefab:PackedScene
var actionUIs:Array[ActionRebind] = []

@export var propertySetupPrefab:PackedScene
var propertyUIs:Array[InputtyPropertyUI]

var unsavedChanges:bool = false

var workingMap:InputtyMap
func _ready():
	
	workingMap = InputtyMap.new()
	workingMap.copyFrom(Inputty.inputMap)
	setup_rebind_ui()
	
	connect("visibility_changed", setup_rebind_ui)
	
	visible = false
	visible = true

func setup_rebind_ui():
	if !visible:
		set_process(false)
		return
	
	set_process(true)
	Inputty._inputRemap = self
	
	#we reload the bindings
	workingMap = InputtyMap.new()
	workingMap.copyFrom(Inputty.inputMap)
	BuildUI()
	unsavedChanges = false
	
	$ScrollContainer.visible = true
	$HBoxContainer/Defaults.focus_mode = FOCUS_ALL
	$HBoxContainer/Defaults.grab_focus()

func _exit_tree():
	if Inputty._inputRemap == self:
		Inputty._inputRemap = null

func loadDefaults():
	cancelRebind()
	workingMap = InputtyMap.new()
	workingMap.copyFrom(Inputty._inputMapDefault)
	unsavedChanges = true
	BuildUI()
	
func applyMap():
	cancelRebind()
	
	for a in workingMap.actions:
		for i in range(0,a.inputs.size(),1):
			if a.inputs[i]==null:
				a.inputs.remove_at(i)
				i-=1
				
	workingMap.applyToMain()
	Inputty.inputMap.saveToFile()
	Inputty.input_binding_changed.emit()
	
	unsavedChanges = false
	exit_requested.emit()

var rebindingActionUI:ActionRebind=null
func cancelRebind(reclaimFocus:bool=false):
	if !rebindingActionUI:
		return
	rebindingActionUI.cancelRebind(reclaimFocus)
	endRebind()
	
func endRebind():
	rebindingActionUI = null
	
func beginRebind(actionUI:ActionRebind):
	rebindingActionUI = actionUI

func BuildUI():
	for i in propertyUIs.size():
		propertyUIs[i].queue_free()
	
	propertyUIs = []
	for i in workingMap.properties.size():
		var newPropertyUI:Control = propertySetupPrefab.instantiate()
		propertyUIs.append(newPropertyUI)
		newPropertyUI.propertyName = workingMap.properties[i].name
		
		newPropertyUI.customProperty = workingMap.properties[i]
		
		$ScrollContainer/GridContainer.add_child(newPropertyUI)
		
	
	for i in actionUIs.size():
		actionUIs[i].queue_free()
	
	actionUIs = []
	
	if actionNames.size()==0:
		#There are no specified actions to make available for rebind
		#We'll just add all of them that allowActionRebinding() permits
		var allActions:Array[StringName] = InputMap.get_actions()
		for act in allActions:
			if allowActionRebinding(act):
				actionNames.append(act)

	for i in actionNames.size():
		#Add UI for rebinding of each action in actionNames
		var newRebindUI:Control = actionRebindPrefab.instantiate()
		actionUIs.append(newRebindUI)
		newRebindUI.actionName = actionNames[i]
		newRebindUI.actionDisplay = actionNames[i]
		if actionDisplayNames.size()>i && actionDisplayNames[i]!="":
			newRebindUI.actionDisplay = actionDisplayNames[i]
		
		newRebindUI.customAction = workingMap.getAction(actionNames[i])
		
		$ScrollContainer/GridContainer.add_child(newRebindUI)
	
func allowActionRebinding(n:StringName):
	if (n.length()>3 and n.substr(0,3)=="ui_"):
		return false
	if (n.length()>1 and n.substr(0,1)=="_"):
		return false
	return true


func _process(_delta):
	if currentJoyName!=Inputty.activeJoyName:
		refreshIcons()


func rebindCheck(event):
	var acceptEvent = false
	if event is InputEventKey:
		acceptEvent = event.pressed != (event.keycode==Key.KEY_CTRL or event.keycode==Key.KEY_ALT or event.keycode==Key.KEY_SHIFT or event.keycode==Key.KEY_META)
	if event is InputEventMouseButton and event.pressed:
		acceptEvent = true
	if event is InputEventJoypadButton and event.pressed:
		acceptEvent = true
	if event is InputEventJoypadMotion and abs(event.axis_value)>0.5:
		acceptEvent = true
	if event is InputEventMIDI and event.pressure>20:
		acceptEvent = true
	

	if acceptEvent:
		unsavedChanges = true
		rebindingActionUI.Rebind(event)
		endRebind()

var currentJoyName:String = "asdf"
func refreshIcons():
	currentJoyName = Inputty.activeJoyName
	for rebindUI in actionUIs:
		rebindUI.refreshAllInputDisplays()
