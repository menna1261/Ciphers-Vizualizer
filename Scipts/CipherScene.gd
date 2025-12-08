extends Control

@onready var cipher_menu = $Panel/ChooseCipher/CipherMenu
@onready var choose_cipher = $Panel/ChooseCipher
@onready var text_entry = $Panel/EnterText/TextEntry
@onready var key_entry = $Panel/EnterKey/KeyEntry
@onready var cipher_text = $CipherText
@onready var grid_container = $GridContainer
@onready var cell = preload("res://Scenes/cell.tscn")
const highlight_style = preload("res://Assets/new_style_box_flat.tres")
const found_style = preload("res://Assets/green_style_box_flat.tres")
@onready var splitted_text = $Splitted_Text


@export var Array2D = []
@export var width = 5
@export var height = 5

var Cipher_res = ""
var alphabet_list = []
var lines_to_draw = []
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
	var i =0
	while(i < plainText_list.size() - 1):
		_get_playfair_output(plainText_list[i],plainText_list[i+1])
		await get_tree().create_timer(4.0).timeout
		i+=2
	#cipher_text.text = Cipher_res
	print("========================Final cipher : ", cipher_text.text)
	
	
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

	var i = 0
	while (i < plainText_list.size()):
		splitted_text.text += plainText_list[i]
		if i < plainText_list.size()-1:
			splitted_text.text += plainText_list[i+1]
		splitted_text.text+= " "
		i+=2
	

func _get_playfair_output(letter1:String , letter2:String):
	var x1 =-1 
	var x2 = -1
	var y1 = -1
	var y2 = -1
	
	for i in 5:
		for j in 5:
			var cell_text = Array2D[i][j].get_child(0).get_child(0).text
			if cell_text == letter1:
				x1 = i 
				y1 = j 
			elif cell_text ==letter2:
				x2 = i 
				y2 = j 
	
	if x1 != -1 and x2!=-1 and y1 != -1 and y2 != -1:
		Array2D[x1][y1].get_child(0).get_child(0).set("theme_override_styles/normal", highlight_style)
		Array2D[x2][y2].get_child(0).get_child(0).set("theme_override_styles/normal", highlight_style)
		if(x1 != x2 and y1!=y2):

			var res1 = Array2D[x1][y2].get_child(0).get_child(0).text
			var res2 = Array2D[x2][y1].get_child(0).get_child(0).text

			await get_tree().create_timer(1.0).timeout	
			cipher_text.text +=res1
			cipher_text.text+=res2
			_create_rectangle(x1, y1, x2 , y2 , x1 , y2 , x2 , y1)
			await get_tree().create_timer(1.0).timeout
			Array2D[x1][y2].get_child(0).get_child(0).set("theme_override_styles/normal", found_style)		
			Array2D[x2][y1].get_child(0).get_child(0).set("theme_override_styles/normal", found_style)
			await get_tree().create_timer(0.3).timeout	
			$DrawingLayer.hide()
			$DrawingLayer.lines_to_draw.clear()
			

			Array2D[x1][y2].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
			Array2D[x2][y1].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
			Array2D[x2][y2].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
			Array2D[x1][y1].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
			await get_tree().create_timer(0.2).timeout
			$DrawingLayer.show()
			

		#Same row
		elif (x1 == x2):
			
			var res1 = Array2D[x1][(y1+1)%5].get_child(0).get_child(0).text
			var res2 = Array2D[x2][(y2+1)%5].get_child(0).get_child(0).text
			await get_tree().create_timer(1.0).timeout
			Array2D[x1][(y1+1)%5].get_child(0).get_child(0).set("theme_override_styles/normal", found_style)
			Array2D[x2][(y2+1)%5].get_child(0).get_child(0).set("theme_override_styles/normal", found_style)

			await get_tree().create_timer(1.0).timeout
			cipher_text.text+=res1
			cipher_text.text+=res2	
			Array2D[x1][(y1+1)%5].get_child(0).get_child(0).set("theme_override_styles/normal", StyleBoxEmpty.new())
			Array2D[x2][(y2+1)%5].get_child(0).get_child(0).set("theme_override_styles/normal", StyleBoxEmpty.new())
			Array2D[x2][y2].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
			Array2D[x1][y1].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
			await get_tree().create_timer(1.0).timeout		
		#Same column
		elif (y1==y2):
			var res1 = Array2D[(x1+1)%5][y1].get_child(0).get_child(0).text
			var res2 = Array2D[(x2+1)%5][y2].get_child(0).get_child(0).text
			await get_tree().create_timer(1.0).timeout
			Array2D[(x1+1)%5][y1].get_child(0).get_child(0).set("theme_override_styles/normal", found_style)
			Array2D[(x2+1)%5][y2].get_child(0).get_child(0).set("theme_override_styles/normal", found_style)

			await get_tree().create_timer(1.0).timeout		
			cipher_text.text+=res1
			cipher_text.text+=res2	
			Array2D[(x1+1)%5][y1].get_child(0).get_child(0).set("theme_override_styles/normal", StyleBoxEmpty.new())
			Array2D[(x2+1)%5][y2].get_child(0).get_child(0).set("theme_override_styles/normal", StyleBoxEmpty.new())
			Array2D[x2][y2].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
			Array2D[x1][y1].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
			await get_tree().create_timer(1.0).timeout		
		
	print("Cipher text : ", Cipher_res)			
	#await get_tree().create_timer(2.0).timeout	
	
func _create_rectangle(L1x, L1y, L2x, L2y, res1x, res1y, res2x, res2y):
	print("inside rectangle ")
	var DL = $DrawingLayer

	var A = DL.to_local(Array2D[L1x][L1y].get_child(0).get_global_position())
	var B = DL.to_local(Array2D[res1x][res1y].get_child(0).get_global_position())
	var C = DL.to_local(Array2D[L2x][L2y].get_child(0).get_global_position())
	var D = DL.to_local(Array2D[res2x][res2y].get_child(0).get_global_position())

	print("A:", A, " B:", B, " C:", C, " D:", D)



	# clear previous lines
	DL.lines_to_draw.clear()


	# Add rectangle edges in order
	DL.lines_to_draw.append({ "a": A, "b": B })
	DL.lines_to_draw.append({ "a": B, "b": C})
	DL.lines_to_draw.append({ "a": C, "b": D })
	DL.lines_to_draw.append({ "a": D, "b": A })

	DL.queue_redraw()

	
func _on_play_fair_pressed():
	cipher_menu.visible = !cipher_menu.visible
	_set_cipher_name("Play Fair")
	_get_input()
	_Create_PlayFair_Matrix()

func _remove_KEY_duplicates():
	for i in Global.KEY.length():
		if(Global.KEY[i] == " "):
			continue
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
