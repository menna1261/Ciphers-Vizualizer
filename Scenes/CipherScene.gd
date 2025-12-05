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

var defaultMenuName = ""


func _ready():
	#get_tree().change_scene_to_file("res://Scenes/ViginereCipher.tscn")
	defaultMenuName = "Choose Cipher"
	
	
func _on_choose_cipher_pressed():
	cipher_menu.visible = !cipher_menu.visible

func _set_cipher_name(CipherName : String):
	choose_cipher.text = CipherName
	
func _on_ceaser_cipher_pressed():
	_set_cipher_name("Ceaser")
	cipher_menu.visible = false
	_get_input()
	
func _on_reset_pressed():
	text_entry.clear()
	key_entry.clear()
	cipher_text.clear()
	choose_cipher.text = defaultMenuName
	
func _Create_PlayFair_Matrix():
	for i in 25:
		var new_cell = cell.instantiate()
		if(Global.KEY != ""):
			if(i<5):
				new_cell.get_child(0).get_child(0).text = Global.KEY[i]
				new_cell.get_child(0).get_child(0).set("theme_override_colors/font_color", Color.YELLOW)
			else:
				new_cell.get_child(0).get_child(0).text = Global.Alphabet[i]
			grid_container.add_child(new_cell)
			_create_Array2D()
	#_print()
	
func _create_Array2D():
	for i in 5 :
		Array2D.append([])
		for j in 5:
			Array2D[i].append(grid_container.get_child(i * 5 + j))
	
func _print():
	for i in range(Array2D.size()):
		for j in range(Array2D[i].size()):  
			print(Array2D[i][j].get_child(0).get_child(0).text)

func _get_input():
	Global.PlainText = text_entry.text
	Global.KEY = key_entry.text
	print("plain text : " , Global.PlainText)

func _on_play_fair_pressed():
	cipher_menu.visible = !cipher_menu.visible
	_set_cipher_name("Play Fair")
	_get_input()
	_Create_PlayFair_Matrix()


func _on_viginere_cipher_pressed() -> void:
	_set_cipher_name("Viginere")
	cipher_menu.visible = false
	_get_input()
	_create_viginere()

func _create_viginere() ->void:
	get_tree().change_scene_to_file("res://Scenes/ViginereCipher.tscn")

func _on_des_cipher_pressed() -> void:
	_set_cipher_name("DES")
	cipher_menu.visible = false
	_get_input()
