extends Control

var ASSEMBLY_MAP := {
	"INC": [0,0],
	"DEC": [0,1],
	"XOR": [0,2],
	"NEXT": [0,3],

	"LOAD": [1,0],
	"STORE": [1,1],
	"INC_MEM": [1,2],
	"NEXT_MEM": [1,3],

	"SKIP0": [2,0],
	"JUMP": [2,1],
	"PC2A": [2,2],
	"NEXT_CTRL": [2,3],

	"OUT": [3,0],
	"IN": [3,1],
	"READ_OUT": [3,2],
	"NEXT_IO": [3,3]
}

func parse_assembly(text: String) -> Array:
	var lines = text.split("\n", true)
	var program := []

	var current_mode = 0
	
	for line in lines:
		line = line.strip_edges()
		if line == "" or line.begins_with(";"):
			continue
		
		var parts = line.split(" ")
		var mnemonic = parts[0].to_upper()
		
		if ASSEMBLY_MAP.has(mnemonic):
			var instr = ASSEMBLY_MAP[mnemonic]
			# Update mode if instruction is NEXT
			current_mode = instr[0]
			program.append(instr[1])
		else:
			push_error("Unknown mnemonic: %s" % mnemonic)
			program.append(0) # insert NOP fallback
		
	return program

func inject_program(cpu: Q2CPU, program: Array) -> void:
	cpu.reset()
	
	for i in range(min(program.size(), cpu.MEMORY.size())):
		cpu.MEMORY[i] = program[i] & 0b11


func _on_button_pressed() -> void:
	inject_program($"..".cpu, parse_assembly($CodeEdit.text))
