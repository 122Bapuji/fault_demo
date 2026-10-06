# ----------------------------------------------------------------------------
# OpenROAD Routing Script for SCL 1200nm for STA
# ----------------------------------------------------------------------------

# Read design files
# Update these paths to your actual SCL120 .lib and .lef locations

# Load the liberty files
read_liberty /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lib/c1d_core_typ.lib

# Read the gate-level netlist (the .v file used to generate your DEF)

read_verilog /././OpenLane/designs/<project directory name>/runs/RUN/results/routing/test_rt_sim.v

# Set the top module name

link_design top_module_name



# Read the parasitics you just generated

read_spef /././OpenLane/designs/<project directory name>/runs/RUN/results/spef/test.spef


create_clock -name CLK -period 8 [get_ports clk]

#virtual clock set up 
#create_clock -name vclk -period 61
#set_input_delay -clock vclk 0.2 [get_ports port_name]
#set_output_delay -clock vclk 0.2 [get_ports port_name]


# Generate reports

report_checks -path_delay min_max -format full_clock_expanded > timing_report.txt
report_tns > tns_report.txt
report_wns > wns_report.txt



write_sdf /././OpenLane/designs/<project directory name>/runs/RUN/results/sta/test.sdf
