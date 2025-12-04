extends Control

@onready var cipher_menu = $Panel/ChooseCipher/CipherMenu
@onready var choose_cipher = $Panel/ChooseCipher
@onready var text_entry = $Panel/EnterText/TextEntry
@onready var key_entry = $Panel/EnterKey/KeyEntry
@onready var cipher_text = $CipherText

var defaultMenuName = ""
var PlainText = ""
var KEY = ""

func _ready():
	defaultMenuName = "Choose Cipher"
	
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
	
