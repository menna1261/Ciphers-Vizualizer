extends Control

@onready var cipher_menu = $Panel/ChooseCipher/CipherMenu
@onready var choose_cipher = $Panel/ChooseCipher
@onready var text_entry = $Panel/EnterText/TextEntry
@onready var key_entry = $Panel/EnterKey/KeyEntry
@onready var cipher_text = $CipherText
@onready var grid_container = $GridContainer
@onready var cell = preload("res://Scenes/cell.tscn")


@export var Array2D = []
@export var width = 5
@export var height = 5

@export var Alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

var defaultMenuName = ""
var PlainText = ""
var KEY = ""

func _ready():
	defaultMenuName = "Choose Cipher"
	_Create_PlayFair_Matrix()

	

	
func _on_choose_cipher_pressed():
	cipher_menu.visible = !cipher_menu.visible

func _set_cipher_name(CipherName : String):
	choose_cipher.text = CipherName
	
func _on_hill_cipher_pressed():
	_set_cipher_name("Hill Cipher")
	cipher_menu.visible = false
	PlainText = text_entry.text
	KEY = key_entry.text
	print("plain text : " , PlainText)
	
func _on_reset_pressed():
	text_entry.clear()
	key_entry.clear()
	cipher_text.clear()
	choose_cipher.text = defaultMenuName
	
func _Create_PlayFair_Matrix():
	
	for i in 25:
		var new_cell = cell.instantiate()
		new_cell.get_child(0).get_child(0).text = Alphabet[i]
		grid_container.add_child(new_cell)
	_create_Array2D()
	_print()
	
func _create_Array2D():
	for i in 5 :
		Array2D.append([])
		for j in 5:
			Array2D[i].append(grid_container.get_child(i * 5 + j))
	
func _print():
	for i in range(Array2D.size()):
		for j in range(Array2D[i].size()):  
			print(Array2D[i][j].get_child(0).get_child(0).text)
