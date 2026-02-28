extends Control


var state = false


func _process(delta: float) -> void:
	if $"..".cpu.running != state:
		state = $"..".cpu.running
		if state:
			$Panel/RichTextLabel2.text = "RUNNING"
		else:
			$Panel/RichTextLabel2.text = "HALTED"
