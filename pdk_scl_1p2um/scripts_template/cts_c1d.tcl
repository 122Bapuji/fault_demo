# ----------------------------------------------------------------------------
# OpenROAD Routing Script for SCL 1200nm for CTS
# ----------------------------------------------------------------------------

# Read design files
# Update these paths to your actual SCL120 .lib and .lef locations

read_liberty /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lib/c1d_core_typ.lib

read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/tech_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/core_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/io_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/corner_c1d.lef

read_db /././OpenLane/designs/<project directory name>/runs/RUN/results/placement/test_plcts.odb

# Define the clock constraints manually since characterization failed
set_cmd_units -time ns -capacitance pF -resistance kOhm -voltage V -current mA

# Create the clock tree
create_clock -name CLK -period 10 [get_ports clk]
set_propagated_clock [all_clocks]

# We use the buffers you identified in your SCL180 library
clock_tree_synthesis -root_buf INVR01 -buf_list "INVR01" -sink_clustering_enable

# Legalize the newly inserted buffers
#hold_slack_margin 0.1
#setup_slack_margin 0.0

repair_clock_nets

detailed_placement

set ::env(FP_FILL_CELL) "FILLER1 FILLER2 FILLER3 FILLER4 FILLER5"
filler_placement -prefix FILLER [list "FILLER1" "FILLER2" "FILLER3" "FILLER4" "FILLER5"]

# Save the result
write_db /././OpenLane/designs/<project directory name>/runs/RUN/results/cts/test_plcts.odb



write_def "/././OpenLane/designs/<project directory name>/runs/RUN/results/cts/test_plcts.def"

