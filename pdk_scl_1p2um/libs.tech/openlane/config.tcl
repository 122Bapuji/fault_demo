# Technology specialized variables
set ::env(RT_MAX_LAYER) "metal2" ;# Change based on how many metal layers scl1200 has
set ::env(PROCESS) 1200 ;# Identifying it as 1.2um/1200nm
set ::env(PDK) "sclc1d"
set ::env(PDK_ROOT) "/././my_dtech/Open_Source_SCL_1.2micron_PDK_digital/open_source_scl_c1d/open_pdks"
# You must point these to the actual files in your scl1200/libs.ref directory
set ::env(TECH_LEF) "$::env(PDK_ROOT)/sclc1d/libs.ref/digital_c1d/lef/tech_c1d.lef"
set ::env(CELL_LEF) "$::env(PDK_ROOT)/sclc1d/libs.ref/digital_c1d/lef/core_c1d.lef"
set ::env(LIB_SYNTH) "$::env(PDK_ROOT)/sclc1d/libs.ref/digital_c1d/lib/scl1u_pads_typ.lib"

# If scl1200 has specific track information
set ::env(TRACKS_INFO_FILE) "$::env(PDK_ROOT)/sclc1d/libs.tech/openlane/tracks.info"
