extends Control


@onready var outport: OutPort = $OutPort

var cpu: Q2CPU
var cycles_per_second: int = 999
var _cycle_accumulator: float = 0.0


func _ready() -> void:
	cpu = Q2CPU.new()
	cpu.attach_device(0, outport)


func _process(delta: float) -> void:
	if not cpu.running:
		return
	
	_cycle_accumulator += delta * cycles_per_second
	
	while _cycle_accumulator >= 1.0:
		cpu.cycle()
		_cycle_accumulator -= 1.0


func _on_run_pressed() -> void:
	cpu.running = true
	$ControlPanel/Panel/RichTextLabel2.text = "RUNNING"


func _on_halt_pressed() -> void:
	cpu.running = false
	$ControlPanel/Panel/RichTextLabel2.text = "HALTED"


func _on_spin_box_value_changed(value: float) -> void:
	cycles_per_second = value
