class_name Q2CPU


var A:    int = 0
var PC:   int = 0
var MODE: int = 0
var LIO:  int = 0
var MEMORY: Array[int] = []

var running: bool = false

const MEM_SIZE        = 256
const ARITHMETIC_MODE = 0
const MEMORY_MODE     = 1
const CONTROL_MODE    = 2
const IO_MODE         = 3

var devices: Dictionary = {}   # port_number -> device


func _init() -> void:
	MEMORY.resize(MEM_SIZE)
	MEMORY.fill(0)


func reset() -> void:
	A = 0
	PC = 0
	MODE = 0
	LIO = 0
	MEMORY.fill(0)


func cycle() -> void:
	var opcode = MEMORY[PC] & 0b11
	PC = (PC + 1) % MEM_SIZE
	
	match MODE:
		ARITHMETIC_MODE: match opcode:
			0: # INC A
				A = (A + 1) & 3
			1: # DEC A
				A = (A - 1) & 3
			2: # XOR with MEMORY[A]
				A = (A ^ MEMORY[A]) & 3
			3: MODE = (MODE + 1) & 3
		MEMORY_MODE: match opcode:
			0: # LOAD
				A = MEMORY[A] & 3
			1: # STORE
				MEMORY[A] = A & 3
			2: # INC RAM[A]
				MEMORY[A] = (MEMORY[A] + 1) & 3
			3: MODE = (MODE + 1) & 3
		2: match opcode:
			0: # SKIP IF A == 0
				if A == 0:
					PC = (PC + 1) % MEM_SIZE
			1: # JUMP MEMORY[A]
				PC = MEMORY[A] % MEM_SIZE
			2: # LOAD PC LOW INTO A
				A = PC & 3
			3: MODE = (MODE + 1) & 3
		3: match opcode:
			0: write_port(MEMORY[A], A)
			1: A = read_port(MEMORY[A]) & 3
			2: # A = LIO (Last I/O value)
				A = LIO & 3
			3: MODE = (MODE + 1) & 3


func attach_device(port: int, device):
	devices[port & 3] = device


func write_port(port: int, value: int) -> void:
	port &= 3
	value &= 3
	
	if not devices.has(port):
		running = false
		return
	
	if devices.has(port):
		devices[port].write(value)
	
	LIO = value


func read_port(port: int) -> int:
	port &= 3
	
	if devices.has(port):
		LIO = devices[port].read() & 3
		return LIO
	
	return 0
