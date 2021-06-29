onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib blk_mem_gen_canvas_opt

do {wave.do}

view wave
view structure
view signals

do {blk_mem_gen_canvas.udo}

run -all

quit -force
