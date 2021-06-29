onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib blk_mem_gen_input_layer_weight_785x64_opt

do {wave.do}

view wave
view structure
view signals

do {blk_mem_gen_input_layer_weight_785x64.udo}

run -all

quit -force
