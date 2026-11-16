extends Node

# Variables to handle where the system might be
enum states { MENU, GAME, CUTSCENES }
enum devices { KEYBOARD, JOYPAD }
var current_state  : states  = states.GAME;         #TODO CHANGE WHEN THE MENU IS SET UP
var current_device : devices = devices.KEYBOARD;                               
const deadzone = 0.2;

# Signals related with every input known in the game (and future to add)
signal state_changed(new_state: states)
signal device_changed(new_device: devices)
signal connection_changed(device_id: int, connected: bool)
signal jump_pressed()
signal jump_released()
signal attack_pressed()
signal pause_pressed()

# Variables related with the inputs to manage this structure better
const MOVE_LEFT  = "input_move_left"
const MOVE_RIGHT = "input_move_right"
const MOVE_UP    = "input_move_up"
const MOVE_DOWN  = "input_move_down"
const ACTION_A   = "input_action_(A)" 
const ACTION_B   = "input_action_(B)" 
const START      = "input_start"
const SELECT     = "input_select"

# Function to change between scenes
func set_state(new_state: states):
	current_state = new_state
	state_changed.emit(new_state)

func _set_device(new_device: devices):
	current_device = new_device
	device_changed.emit(new_device)

# Function to set the connection of the devices and the function
func _ready() -> void:
	Input.get_connected_joypads() 
	Input.joy_connection_changed.connect(_joy_connection_changed)

# Main functionality
func _unhandled_input(event: InputEvent) -> void:
	match current_state:
		states.MENU:
			_menu_inputs(event)
		states.GAME:
			_player_movement_inputs(event)
		states.CUTSCENES:
			#TODO We haven't implemented the CUTSCENES YET
			pass

# Check for connection with the devices
func _input(event: InputEvent) -> void:
	# We check for the device that may be connected
	if ((event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value) > deadzone)) and current_device != devices.JOYPAD):
		_set_device(devices.JOYPAD)
	elif ((event is InputEventKey or event is InputEventMouse) and current_device != devices.KEYBOARD):
		_set_device(devices.KEYBOARD)

# Functionality for the inputs for player movement
func _player_movement_inputs(event: InputEvent):
	if (event.is_action_pressed(ACTION_B)):       #IF ACTION_B PRESSED; PLAYER JUMPS
		jump_pressed.emit()
	elif (event.is_action_released(ACTION_B)):    #IF ACTION_B RELEASED; JUMP MIGHT CHANGE?
		jump_released.emit()
	elif (event.is_action_pressed(ACTION_A)):     #IF ACTION_A PRESSED; PLAYER ATTACKS
		attack_pressed.emit() 
	elif (event.is_action_pressed(START)):          #IF START IS PRESSED, WE CHANGE TO THE MENU STATE
		pause_pressed.emit()
		set_state(states.MENU)

# Functionality for the menu interactions
func _menu_inputs(event: InputEvent):
	if (event.is_action_pressed(START) or event.is_action_pressed(ACTION_B)):
		#CHANGE TO GAME BACK AGAIN 
		#TODO (IF THERE IS MULTIPLE LAYERS; WE HAVE TO CHANGE THE B FUNCTION)
		set_state(states.GAME)

# Functionality to indicate that the device was connected
func _joy_connection_changed(device_id: int, connected: bool):
	print("ID de dispositivo: ", device_id)
	print("Estado de conexión: ", connected)
	connection_changed.emit(device_id, connected)

# Function to return the vector desired
func get_move_vector() -> Vector2:
	if current_state != states.GAME:
		return Vector2.ZERO
	return Input.get_vector(MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN, deadzone)

