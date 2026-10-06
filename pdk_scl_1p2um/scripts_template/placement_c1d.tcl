# ----------------------------------------------------------------------------
# OpenROAD Routing Script for SCL 1200nm for PLACEMENT
# ----------------------------------------------------------------------------

# Read design files
# Update these paths to your actual SCL120 .lib and .lef locations
read_liberty /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lib/c1d_core_typ.lib

read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/tech_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/core_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/io_c1d.lef
read_lef /././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks/sclc1d/digital_c1d/lef/corner_c1d.lef


read_def "/././OpenLane/designs/<project directory name>/runs/RUN/results/floorplan/test_pdn.def"

#make_placement_blockage -boundary {2237.5 993.7 2240.1 4022.4} -type soft 
# Direct placement without any variable dependencies
#set_placement_padding -global -left 2 -right 2
global_placement -density 0.23

detailed_placement 


check_placement -verbose
#set ::env(FP_FILL_CELL) "FILLER1 FILLER2 FILLER3 FILLER4 FILLER5"
#filler_placement -prefix FILLER [list "FILLER1" "FILLER2" "FILLER3" "FILLER4" "FILLER5"]

write_def "/././OpenLane/designs/<project directory name>/runs/RUN/results/placement/test_pl.def"

puts "Success: Manual placement reached."

write_db /././OpenLane/designs/<project directory name>/runs/RUN/results/placement/test_plcts.odb


