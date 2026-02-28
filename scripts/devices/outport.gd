class_name OutPort
extends Q2Device

@export var label: RichTextLabel

var buffer: Array[int] = []

func write(value: int) -> void:
	value &= 0b11
	buffer.append(value)
	
	if buffer.size() == 4:
		var byte: int = 0
		
		for i in range(4):
			byte = (byte << 2) | buffer[i]
		
		buffer.clear()
		
		var character := char(byte & 0x7F)
		label.append_text(character)

func read() -> int:
	return 0


func _on_button_pressed() -> void:
	label.clear()
