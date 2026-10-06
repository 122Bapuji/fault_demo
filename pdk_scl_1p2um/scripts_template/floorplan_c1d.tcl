# ----------------------------------------------------------------------------
# OpenROAD Routing Script for SCL 1200nm for FLOORPLAN
# ----------------------------------------------------------------------------

# Read design files
# Update these paths to your actual SCL120 .lib and .lef locations

read_liberty /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lib/c1d_core_typ.lib

read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/tech_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/core_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/io_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/corner_c1d.lef

read_verilog /././OpenLane/designs/<project directory name>/src/test_syn.v

link_design top_module_name

# Read SDC if it exists  -does not exist in shift register case.
if { [file exists /home/scl/EDA/openlane/OpenLane/OpenLane/designs/check_stdcells/src/counter_pad.sdc] } {
    read_sdc /home/scl/EDA/openlane/OpenLane/OpenLane/designs/check_stdcells/src/counter_pad.sdc
}

# The manual command that worked in your terminal
# Using 'eval' ensures the list from DIE_AREA is parsed correctly
initialize_floorplan -site $::env(PLACE_SITE) -die_area "$::env(DIE_AREA)" -core_area "$::env(CORE_AREA)"


# ---------------------------------------------------------
set block [[ord::get_db_block] getRows]
set count 0
foreach row $block {
    if { [expr $count % 2] != 0 } {
        # Delete every odd-numbered row to create a 1-row gap
        odb::dbRow_destroy $row
    }
    incr count
}
puts "Custom Row Modification: Removed alternating rows to prevent overlaps."
# ---------------------------------------------------------

# 4. Save the result
set output_def "/././OpenLane/designs/<project directory name>/runs/RUN/results/floorplan/test_fp.def"


write_def $output_def

puts "Success: Floorplan saved to results folder."

