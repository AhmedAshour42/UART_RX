vlib work
vlog -f src_file.list
vlog Top_Tb.v
vsim -voptargs=+acc work.Top_Tb
add wave -position insertpoint  \
sim:/Top_Tb/clk \
sim:/Top_Tb/rst \
sim:/Top_Tb/RX_IN \
sim:/Top_Tb/Prescale \
sim:/Top_Tb/PAR_EN \
sim:/Top_Tb/PAR_TYP
add wave -position end  sim:/Top_Tb/uut/FSM_RX/par_chk_en
add wave -position insertpoint  \
sim:/Top_Tb/uut/EDGE_BIT_COUNTER/edge_cnt \
sim:/Top_Tb/uut/EDGE_BIT_COUNTER/bit_cnt
add wave -position insertpoint  \
sim:/Top_Tb/uut/DESERIALIZER_RX/counter
add wave -position insertpoint  \
sim:/Top_Tb/uut/DESERIALIZER_RX/Data_reg
add wave -position insertpoint  \
sim:/Top_Tb/uut/DATA_SAMPLING_RX/sum_sample
add wave -position insertpoint  \
sim:/Top_Tb/uut/DATA_SAMPLING_RX/sampled_bit
add wave -position insertpoint  \
sim:/Top_Tb/uut/FSM_RX/current_state
add wave -position insertpoint  \
sim:/Top_Tb/uut/FSM_RX/PAR_EN \
sim:/Top_Tb/uut/FSM_RX/dat_samp_en \
sim:/Top_Tb/uut/FSM_RX/enable \
sim:/Top_Tb/uut/FSM_RX/par_chk_en \
sim:/Top_Tb/uut/FSM_RX/strt_chk_en \
sim:/Top_Tb/uut/FSM_RX/stp_chk_en \
sim:/Top_Tb/uut/FSM_RX/deser_en
add wave -position insertpoint  \
sim:/Top_Tb/uut/FSM_RX/Par_err \
sim:/Top_Tb/uut/FSM_RX/strt_glitch \
sim:/Top_Tb/uut/FSM_RX/stp_err
add wave -position insertpoint  \
sim:/Top_Tb/data_valid \
sim:/Top_Tb/P_DATA
run -all
