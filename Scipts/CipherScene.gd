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

var alphabet_list = []
var plainText_list =[]
var defaultMenuName = ""
var end = 0

func _ready():
	#get_tree().change_scene_to_file("res://Scenes/ViginereCipher.tscn")
	defaultMenuName = "Choose Cipher"
	for i in range(255):
		Global.arr.append(0)
	Global.keyArr.clear()
	
	for c in Global.Alphabet:
		if c == "j":  # merge i/j
			continue
		alphabet_list.append(c)


	
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
	var matrix_letters = []
	_remove_KEY_duplicates()
	for c in Global.keyArr:
		matrix_letters.append(c)
		

	# Add remaining alphabet letters
	for c in alphabet_list:
		if c not in Global.keyArr:
			matrix_letters.append(c)
	
	for i in range(25):
		var new_cell = cell.instantiate()
		new_cell.get_child(0).get_child(0).text = matrix_letters[i]
		if(i < Global.keyArr.size()):
			new_cell.get_child(0).get_child(0).set("theme_override_colors/font_color", Color.YELLOW)
		
		grid_container.add_child(new_cell)

	#lastCell.get_child(0).get_child(0).text = Global.Alphabet[24] + "/" + Global.Alphabet[25]
	_create_Array2D()
	
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
	_remove_KEY_duplicates()
	_split_plain_text()
	

func _split_plain_text():
	for i in range(Global.PlainText.length()):
		var letter = Global.PlainText[i]
		if letter == " ":
			continue
		if i<Global.PlainText.length() -1 and letter == Global.PlainText[i+1]:
			plainText_list.append (Global.PlainText[i])
			plainText_list.append("x")
			i+=1
		else :
			plainText_list.append (Global.PlainText[i])
	
	print("Plain text : ", plainText_list)

func _get_playfair_output():
	pass

func _on_play_fair_pressed():
	cipher_menu.visible = !cipher_menu.visible
	_set_cipher_name("Play Fair")
	_get_input()
	_Create_PlayFair_Matrix()

func _remove_KEY_duplicates():
	for i in Global.KEY.length():
		var freq = Global.arr[Global.KEY.unicode_at(i)]
		if(freq == 0):		
			Global.arr[Global.KEY.unicode_at(i)] +=1
			Global.keyArr.append(Global.KEY[i])

	for i in Global.keyArr.size():
		print(Global.keyArr[i])	
		

func _on_viginere_cipher_pressed() -> void:
	_set_cipher_name("Viginere")
	cipher_menu.visible = false
	_get_input()
	_create_viginere()

func _create_viginere() ->void:
	get_tree().change_scene_to_file("res://Scenes/ViginereCipher.tscn")

func _create_des() ->void:
	get_tree().change_scene_to_file("res://Scenes/DesCipher.tscn")

func _on_des_cipher_pressed() -> void:
	_set_cipher_name("DES")
	cipher_menu.visible = false
	_get_input()
	_create_des()
