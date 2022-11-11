extends Node

var start_time
var target_time
var stopped = false
var loop = false
signal timeout

func _init(newtime):
	target_time = newtime
	start_time = OS.get_ticks_msec()

func _process(delta):
	if stopped:return
	if OS.get_ticks_msec() - start_time >= target_time: timer_done()
	
func reset(newtime = null):
	start_time = OS.get_ticks_msec()
	if newtime:
		target_time = newtime
	stopped = false

func get_elapsed_time_in_ms():
	return OS.get_ticks_msec() - start_time

func timer_done():
	emit_signal("timeout")
	if loop:
		reset()
	else: stopped = true
