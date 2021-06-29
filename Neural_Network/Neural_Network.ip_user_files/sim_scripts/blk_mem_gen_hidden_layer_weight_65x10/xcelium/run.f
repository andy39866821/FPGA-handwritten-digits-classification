-makelib xcelium_lib/xpm -sv \
  "D:/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_4 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../Neural_Network.srcs/sources_1/ip/blk_mem_gen_hidden_layer_weight_65x10/sim/blk_mem_gen_hidden_layer_weight_65x10.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

