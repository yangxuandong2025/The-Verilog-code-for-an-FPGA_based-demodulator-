# Copyright (C) 2018  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details.

# Quartus Prime: Generate Tcl File for Project
# File: AM_demod_AC609.tcl
# Generated on: Sun Mar 15 15:33:29 2026

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "AM_demod_AC609"]} {
		puts "Project AM_demod_AC609 is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists AM_demod_AC609]} {
		project_open -revision AM_demod_AC609 AM_demod_AC609
	} else {
		project_new -revision AM_demod_AC609 AM_demod_AC609
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone IV E"
	set_global_assignment -name DEVICE EP4CE10F17C8
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.0.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "20:37:13  MARCH 13, 2026"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.0.0 Standard Edition"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name TIMING_ANALYZER_MULTICORNER_ANALYSIS ON
	set_global_assignment -name NUM_PARALLEL_PROCESSORS 8
	set_global_assignment -name VERILOG_FILE ../rtl/FM.v
	set_global_assignment -name VERILOG_FILE ../rtl/CM.v
	set_global_assignment -name VERILOG_FILE ../rtl/AM.v
	set_global_assignment -name VERILOG_FILE ../rtl/uart_cmd_decoder_simple.v
	set_global_assignment -name VERILOG_FILE ../rtl/uart_byte_tx.v
	set_global_assignment -name VERILOG_FILE ../rtl/uart_byte_rx.v
	set_global_assignment -name VERILOG_FILE src/AM_demod_AC609.v
	set_global_assignment -name SDC_FILE AM_demod_AC609.sdc
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name DEVICE_FILTER_PACKAGE FBGA
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 256
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 8
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
	set_location_assignment PIN_E1 -to Clk
    set_location_assignment PIN_M2 -to Rst_n
    set_location_assignment PIN_M1 -to send_en
    set_location_assignment PIN_D4 -to Rs232_Rx
    set_location_assignment PIN_C3 -to Rs232_Tx
    set_location_assignment PIN_R1 -to Tx_Done
    set_location_assignment PIN_P2 -to uart_state
    set_location_assignment PIN_G15 -to AD_CLK
    set_location_assignment PIN_F16 -to AD[7]
	set_location_assignment PIN_F15 -to AD[6]
	set_location_assignment PIN_D16 -to AD[5]
	set_location_assignment PIN_D15 -to AD[4]
	set_location_assignment PIN_C16 -to AD[3]	
	set_location_assignment PIN_C15 -to AD[2]
	set_location_assignment PIN_B16 -to AD[1]
	set_location_assignment PIN_B14 -to AD[0]
	
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to Clk
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to Rst_n 
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to send_en
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to Rs232_Rx
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to Rs232_Tx
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to Tx_Done
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart_state	 
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AD_CLK
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AD[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AD[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AD[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AD[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AD[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AD[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AD[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AD[0]	
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad_data[7]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad_data[6]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad_data[5]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad_data[4]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad_data[3]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad_data[2]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad_data[1]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ad_data[0]


	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
